require 'rspec'

require_relative 'examples/describe_errors'

# Describes an operation
#
# Builds a describe block that:
# - includes Rack::Test::Methods
# - defines <b>app</b> method that returns the service
# - defines <b>response</b> method
#
# @param operation the operation being specified, ex: GET /profiles
# @param service the Service (rack app) that exposes the operation
def describe_operation(operation, service, &block)

  describe(operation) do
    include Rack::Test::Methods

    define_method :app do
      service
    end

    define_method :method_missing do |m, *args, &block|
      if m.to_s =~ /_path$/
	      service.public_send m, *args, &block
      else
	      super(m, *args, &block)
      end
    end

    def response
      if @response && @response.wraps?(last_response)
        return @response
      else
        @response = OperationResponse.new(last_response)
      end
    end


    define_singleton_method :describe_errors do |errors_spec|
      errors_spec.each do |e, status_code|

        __caller = caller[2..-1]
        it "raises #{e} with status = #{status_code}", :caller => __caller do

          Angus::RSpec::Examples::DescribeErrors.mock_service(service, e, self) do
            get '/'

            if response.http_status_code != status_code
              e = RSpec::Expectations::ExpectationNotMetError.new(
                "Expected status: #{status_code}, got: #{response.http_status_code}"
              )
              e.set_backtrace(__caller)
              raise e
            end
          end

        end
      end
    end

    instance_eval(&block)
  end
end
