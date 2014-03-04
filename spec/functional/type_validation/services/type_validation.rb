require 'angus'

module Spec
  module Functional

    class TypeValidation < Angus::Base
      def configure
        register :users
      end
    end

  end
end