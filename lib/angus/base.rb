require 'json'

require_relative 'resource_definition'
require_relative 'request_handler'
require_relative 'base_resource'

require_relative 'renders/base'
require_relative 'marshallings/base'
require_relative 'base_actions'

require 'picasso/sdoc'

module Angus
  class Base < RequestHandler
    include BaseActions

    FIRST_VERSION = '0.1'

    def initialize
      super

      @resources_definitions = []
      @version = FIRST_VERSION
      @name = self.class.name.downcase
      @configured = false
      @definitions = nil

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
      @definitions = Picasso::SDoc::DefinitionsReader.service_definition('definitions')

      configure

      @configured = true
    end

    def service_name
      @definitions.name
    end

    #def discover_paths
    #  {
    #    'doc' => doc_path,
    #    'api' => api_path
    #  }
    #end

    def register(resource_name, options = {})
      resource_definition = ResourceDefinition.new(resource_name, @definitions)

      @resources_definitions << resource_definition
    end

    #def register_base_routes
    #  router.on(:get, '/') do
    #    render discover_paths
    #  end
    #
    #  router.on(:get, base_path) do
    #    render discover_paths
    #  end
    #
    #  router.on(:get, doc_path) do
    #    render(Picasso::SDoc::HtmlFormatter.format_service(@definitions), format: :html)
    #  end
    #end

    #def doc_path
    #  "#{base_path}/doc"
    #end
    #
    #def api_path
    #  "#{base_path}/api"
    #end

    def base_path
      "/#{service_name}"
    end

    def register_resource_routes(resource_definition)
      resource_definition.operations.each do |operation|
        method  = operation.method.to_sym
        op_path = "#{api_path}#{operation.path}"

        response_metadata = resource_definition.build_response_metadata(operation.response_elements)

        router.on(method, op_path) do |env, params|
          request = Rack::Request.new(env)
          params  = Params.indifferent_params(params)

          resource = resource_definition.resource_class.new(request, params)

          begin
            response = resource.send(operation.code_name) || {}

            messages = response.delete(:messages)

            response = build_data_response(response, response_metadata, messages)

            @response.write(response)
          rescue Exception => error
            #return if handled_exceptions(error)

            # TODO allow rescue_from Exception, with: :testing
            puts error.inspect

            #status_code = get_error_status_code(error)

            #response = build_error_response(error)

            #@response.status = status_code
            #@response.write(response)
            # TODO Handle exceptions
          end
        end
      end
    end

  end
end