module Angus
  module Exceptions

    class InvalidRequestFormat < StandardError
      def message
        'Invalid request format'
      end
    end

  end
end