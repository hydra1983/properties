module Properties
  class EvaluatorFactory
    def create(context)
      Evaluator.new(context)
    end
  end

  class Evaluator
    def initialize(context)
      @context = context
    end

    def evaluate(value)
      data = /\$\{([^\}]+)\}/.match(value)
      return value if data.nil?

      value.gsub(/\$\{([^\}]+)\}/) do
        name = $1
        if @context.has_key?(name)
          evaluate(@context[name])
        else
          "${#{name}}"
        end
      end
    end
  end
end