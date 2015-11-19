module Angus
  module Exceptions

    class MissingParameterError < StandardError

      def initialize(parameter_name = nil)
        @parameter_name = parameter_name
      end

      def message
        "The parameter #@parameter_name is missing."
      end
    end

  end
end