module Angus
  module Exceptions

    class InvalidValueError < StandardError
      def initialize(param = nil, value = nil)
        @param = param
        @value = value
      end

      def message
        "Invalid value #@value for param #@param"
      end
    end

  end
end