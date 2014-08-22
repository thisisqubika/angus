require 'json'
require 'logger'

require_relative 'resource_definition'
require_relative 'request_handler'
require_relative 'base_resource'
require_relative 'responses'

require_relative 'renders/base'
require_relative 'marshallings/base'
require_relative 'base_actions'
require_relative 'proxy_actions'
require_relative 'definition_reader'

require_relative 'utils/params_validator'

require 'angus/sdoc'

module Angus
  class Base < RequestHandler
    include BaseActions
    include ProxyActions

    FIRST_VERSION = '0.1'

    PRODUCTION_ENV        = :production
    DEVELOPMENT_ENV       = :development
    TEST_ENV              = :test
    DEFAULT_ENV           = DEVELOPMENT_ENV
    DEFAULT_DOC_LANGUAGE  = :en

    attr_reader :definitions

    attr_accessor :default_doc_language
    attr_accessor :validate_params

    def initialize
      super

      @resources_definitions  = []
      @version                = FIRST_VERSION
      @name                   = self.class.name.downcase
      @configured             = false
      @definitions            = nil
      @logger                 = Logger.new(STDOUT)
      @default_doc_language   = DEFAULT_DOC_LANGUAGE
      @validate_params        = :return_error

      configure!

      after_configure
    end

    def after_configure
      super

      register_base_routes
      register_resources_routes
    end

    def register_resources_routes
      @resources_definitions.each do |resource|
        register_resource_routes(resource)
      end
    end

    def production?
      environment_name.to_sym == PRODUCTION_ENV
    end

    def development?
      environment_name.to_sym == DEVELOPMENT_ENV
    end

    def test?
      environment_name.to_sym == TEST_ENV
    end

    def environment_name
      ENV['RACK_ENV'] || DEFAULT_ENV
    end

    def configured?
      @configured
    end

    def configure
      warn 'Empty configuration for service.'
    end

    def configure!
      raise 'Already configured' if configured?

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
        method  = operation.http_method.to_sym
        op_path = "#{api_path}#{operation.path}"

        response_metadata = resource_definition.build_response_metadata(operation.response_elements)

        router.on(method, op_path) do |env, params|
          request  = Rack::Request.new(env)
          params   = Params.indifferent_params(params)
          response = Response.new

          resource = resource_definition.resource_class.new(request, params, operation)

          if validate_params == :return_error
            resource.run_validations!
          end

          resource.run_before_filters

          begin
            op_response = resource.send(operation.code_name)
          rescue Exception
            resource.run_after_filters(response)
            raise
          end

          op_response = {} unless op_response.is_a?(Hash)

          messages = op_response.delete(:messages)

          op_response = build_data_response(op_response, response_metadata, messages)

          response.write(op_response)

          resource.run_after_filters(response)

          response
        end
      end
    end

  end
end