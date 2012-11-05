require 'stringio'

require "properties/version"
require "properties/evaluator"
require "properties/evaluator/rubyevaluator"

module Properties
  class Properties
    def initialize(evaluator_factory = nil)
      @@properties ||= {}
      @evaluator_factory = evaluator_factory.nil? ? EvaluatorFactory.new : evaluator_factory
    end

    def respond_to?(name)
      super || @@properties.key?(name.to_sym)
    end

    def load(file)
      if File.exists?(file) and File.file?(file)
        ___parse___(IO.read(file)).each do |prop|
          @@properties[prop.name.to_sym] = prop.value
        end
      end
    end

    def dump
      msg = ""
      @@properties.each do |name,value|
        msg += "#{name}=#{___evaluate___(value)}\n"
      end
      msg
    end

  private
    def method_missing(name, *args, &blk)
      if name.to_s =~ /=$/
        @@properties[$`.to_sym] = args.first
      elsif @@properties.has_key?(name.to_sym)
        ___evaluate___(@@properties[name.to_sym])     
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

      (index2 == value.size - 1) ? -1 : index2
    end

    def ___evaluate___(value)
      @evaluator ||= @evaluator_factory.create(@@properties)
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