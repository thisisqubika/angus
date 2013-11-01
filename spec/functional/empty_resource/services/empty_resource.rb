require 'angus'

module Spec
  module Functional

    class EmptyResource < Angus::Base
      def configure
        register :users
      end
    end

  end
end