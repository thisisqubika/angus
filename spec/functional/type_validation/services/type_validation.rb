require 'angus'

module Spec
  module Functional

    class TypeValidation < Angus::Base
      def configure
        register :admins
      end
    end

  end
end