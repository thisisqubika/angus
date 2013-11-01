require 'angus'

module Spec
  module Functional

    class Basic < Angus::Base
      def configure
        register :users
      end
    end

  end
end