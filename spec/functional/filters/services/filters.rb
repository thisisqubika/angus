require 'angus'

module Spec
  module Functional

    class Filters < Angus::Base
      def configure
        register :users
      end
    end

  end
end