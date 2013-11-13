require 'json'
require 'logger'

require_relative 'resource_definition'
require_relative 'request_handler'
require_relative 'base_resource'
require_relative 'responses'

require_relative 'renders/base'
require_relative 'marshallings/base'
require_relative 'base_actions'

require 'angus/sdoc'

module Angus
  class Base < RequestHandler
    include BaseActions

    FIRST_VERSION = '0.1'

    def initialize
      super

      @resources_definitions = []
      @version = FIRST_VERSION
      @name = self.class.name.downcase
      @configured  = false
      @definitions = nil
      @logger      = Logger.new(STDOUT)

      configure!

      register_base_routes
      register_resources_routes
    end

    def register_resources_routes
      @resources_definitions.each do |resource|
        register_resource_routes(resource)
      end
    end

    def configured?
      @configured
    end

    # TODO ver que hacer
    def configure
    end

    def configure!
      raise 'Already configured' if configured?

      # TODO ver como hacer configurable
      @definitions = Angus::SDoc::DefinitionsReader.service_definition('definitions')

      configure

      @configured = true
    end

    def service_code_name
      @definitions.code_name
    end

    def service_version
      @definitions.version
    end

    def register(resource_name, options = {})
      resource_definition = ResourceDefinition.new(resource_name, @definitions)

      @resources_definitions << resource_definition
    end

    def base_path
      "/#{service_code_name}"
    end

    def register_resource_routes(resource_definition)
      resource_definition.operations.each do |operation|
        method  = operation.method.to_sym
        op_path = "#{api_path}#{operation.path}"

        response_metadata = resource_definition.build_response_metadata(operation.response_elements)

        router.on(method, op_path) do |env, params|
          request = Rack::Request.new(env)
          params = Params.indifferent_params(params)
          response = Response.new

          resource = resource_definition.resource_class.new(request, params)
          response['Content-Type'] = 'application/json'

          begin
            op_response = resource.send(operation.code_name)

            op_response = {} unless op_response.is_a?(Hash)

            messages = op_response.delete(:messages)

            op_response = build_data_response(op_response, response_metadata, messages)

            response.write(op_response)

            response
          rescue Exception => error
            status_code = get_error_status_code(error)
            if status_code == Angus::Responses::HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR
              @logger.error("An exception occurs on #{resource.class.name}##{operation.code_name}")
              @logger.error(error)
            end
            error_response = build_error_response(error)

            response.status = status_code
            response.write(error_response)

            response
          end
        end
      end
    end

  end
end