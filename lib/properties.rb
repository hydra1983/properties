require 'stringio'

require "properties/version"
require "properties/holder"
require "properties/evaluator"
require "properties/evaluator/rubyevaluator"

module Properties
  class Properties
    def initialize(opts = {})
      @properties ||= opts.fetch(:properties_holder, PropertiesHolder.new)
      @evaluator_factory = opts.fetch(:evaluator_factory, EvaluatorFactory.new)
    end

    def [](name)
      ___evaluate___(@properties[name.to_sym]) 
    end

    def []=(name,value)
      @properties[name.to_sym] = value
    end

    def load(path,opts= {:force => true})
      if opts[:force]
        raise "Path #{path} does not exist" unless File.exists?(path)
        raise "#Path #{path} is a not a file" unless File.file?(path)
      end

      ___parse___(IO.read(path)).each do |prop|
        self[prop.name] = prop.value
      end
    end

    def dump
      msg = ""
      @properties.each do |name,value|
        msg += "#{name}=#{___evaluate___(value)}\n"
      end
      msg
    end

    def has_key?(name) 
      @properties.key?(name.to_sym)
    end

    def has_value?(name)
      result = has_key?(name)
      if result
        value = self[name]
        result ||= !(value.nil? || value == "$#{name.to_s}")
      end
      result
    end

    def respond_to?(name)
      super || has_key?(name)
    end

    private
    def method_missing(name, *args, &blk)
      if name.to_s =~ /=$/
        self[$`] = args.first
      elsif @properties.has_key?(name.to_sym)
        self[name]
      else
        raise %Q{No property "#{name}" defined}
      end
    end

    def ___parse___(value)
      return {} if value.nil? or value.empty?
         
      value = value.gsub(/\t/,"")
      lines = StringIO.new(value).readlines
      multiline = false
      props = []
      
      i = -1
      while (i = i + 1) < lines.size
        s = lines[i].strip
        if !s.empty? and !s.start_with?('#') and !s.start_with?('!')
          if multiline
            props[props.size - 1] = props[props.size - 1][0..-2] + s
          else
            props.push(s)
          end

          multiline = s.end_with?('\\')
        end
      end

      i = props.size
      while (i = i -1) > -1
        s = props[i]
        split_index = ___get_split_index___(s)
        
        if split_index == -1
          props.delete_at(i)
          next
        end

        name = s[0..(split_index - 1)]
        name = name.strip unless name.nil?
        value = s[(split_index + 1)..-1]
        value = value.strip unless value.nil?
        props[i] = Property.new(name, value)
      end

      props
    end

    def ___get_split_index___(value)
      s = %Q{= :}
      n = 2
      index1 = 0
      index2 = value.size
      while (n = n -1) > -1
        index1 = value.index(s[n])
        index2 = index1 if !index1.nil? and index1 < index2
      end
      index2
    end

    def ___evaluate___(value)
      @evaluator ||= @evaluator_factory.create(@properties)
      @evaluator.evaluate(value)
    end

    class Property
      attr_accessor :name, :value
      def initialize(name,value)
        @name = name
        @value = value
      end
    end
  end
end