module Angus
  module Marshalling

    class InvalidGetterError < StandardError

      def initialize(getter, bc_first_line = nil)
        @getter = getter
        @bc_first_line = bc_first_line
      end

      def message
        "The requested getter (#@getter) does not exist. #@bc_first_line"
      end
    end

  end
end