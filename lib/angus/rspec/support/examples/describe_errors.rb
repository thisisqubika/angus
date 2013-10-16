module Angus
  module RSpec
    module Examples
      module DescribeErrors

        # Mock a base service by redefining .app method, yields the given block, and
        #   restores the original .app method
        #
        # @param [Class] Class that responds to .get
        # @param error Exception that will be raised when executing a get route
        # @param [#app] example Runing example
        def self.mock_service(base, error, example, &block)

          mock = Class.new(base) do
            get '/' do
              raise error
            end
          end

          example.define_singleton_method :app do
            mock
          end

          begin
            yield
          ensure
            example.define_singleton_method :app do
              base
            end
          end
        end

      end
    end
  end
end
