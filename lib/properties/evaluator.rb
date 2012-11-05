module Properties
  class EvaluatorFactory
    def create(context)
      Evaluator.new(context)
    end
  end

  class Evaluator
    class << self
      def default_value(name)
        "${#{name}}"  
      end
    end
    def initialize(context)
      @context = context
    end

    def evaluate(src_value)
      data = /\$\{([^\}]+)\}/.match(src_value)
      return src_value if data.nil?

      src_value.gsub(/\$\{([^\}]+)\}/) do
        name = $1
        if @context.has_key?(name.to_sym)
          value = evaluate(@context[name.to_sym])
          value.nil? ? Evaluator.default_value(name) : value
        else
          Evaluator.default_value(name)
        end
      end
    end
  end
end