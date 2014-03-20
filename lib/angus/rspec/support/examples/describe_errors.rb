module Angus
  module RSpec
    module Examples
      module DescribeErrors

        # Mock a base service by redefining .app method, yields the given block, and
        #   restores the original .app method
        #
        # @param [Class] Class that responds to .get
        # @param error Exception that will be raised when executing a get route
        # @param [#app] example Running example
        def self.mock_service(base, error, example, &block)

          base_class = if base.is_a?(Class)
                         base
                       else
                         base.class
                       end

          mock = Class.new(base_class) do
            def initialize(base, error)
              @base = base
              @error = error

              super()

              router.on(:get, '/error') do
                raise error
              end
            end

            def class
              @base
            end
          end

          example.define_singleton_method :app do
            mock.new(base_class, error)
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