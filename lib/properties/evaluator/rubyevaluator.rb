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

    def evaluate(value)
      value = super
      data = /\#\{([^\}]+)\}/.match(value)
      return value if data.nil?
      value.gsub(/\#\{([^\}]+)\}/){@built_in.instance_eval($1)}
    end

    class BuiltInMethods
      def read(file)
        IO.read(file)
      end
    end
  end
end