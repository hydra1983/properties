require 'properties/evaluator'

module Properties
  class RubyEvaluatorFactory
    def create(context)
      RubyEvaluator.new(context)
    end
  end

  class RubyEvaluator < Evaluator
    def initialize(context)
      super
      @built_in = BuiltInMethods.new
    end

    def evaluate(src_value)
      src_value = super
      data = /\#\{([^\}]+)\}/.match(src_value)
      return src_value if data.nil?
      src_value.gsub(/\#\{([^\}]+)\}/){@built_in.instance_eval($1)}
    end

    class BuiltInMethods
      def read(file)
        IO.read(file)
      end
    end
  end
end