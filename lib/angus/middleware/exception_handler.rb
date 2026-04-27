require_relative '../definition_reader'
require_relative '../responses'
require_relative '../status_codes'
require_relative '../../../lib/angus/renders/json_render'

module Angus
  module Middleware
    class ExceptionHandler
      include Angus::StatusCodes

      JSON_HEADERS = { 'Content-Type' => 'application/json' }.freeze

      def initialize(app)
        @app = app
        @definition_reader =
          Angus::DefinitionReader.new(app.base_middleware.definitions)
      end

      def call(env)
        dup.call!(env)
      end

      def call!(env)
        @app.call(env)
      rescue Exception => exception
        rack_error_response(exception)
      end

      private

      # Builds a Rack-compatible error response
      #
      # @param [Exception] exception
      # @return [Array] Rack response tuple
      def rack_error_response(exception)
        [
          status_code(exception),
          JSON_HEADERS,
          [build_error_response(exception)]
        ]
      end

      # Builds a service error response
      #
      # @param [Exception] error
      # @return [String] JSON serialized error response
      def build_error_response(error)
        JsonRender.convert(
          status: :error,
          messages: messages_from_error(error)
        )
      end

      # Returns an array of error messages to be sent in the response
      #
      # If {error} responds to :errors, one message is returned per error entry.
      # If {error} responds to :error_key, the message definition is used.
      # Otherwise a generic fallback message is returned.
      #
      # Each message returned is a hash with:
      #  - level
      #  - key
      #  - dsc
      #
      # @param [Exception] error
      # @param [Symbol] level
      #
      # @return [Array<Hash>]
      def messages_from_error(error, level = :error)
        if error.respond_to?(:errors)
          build_errors_from_collection(error.errors, level)
        elsif error.respond_to?(:error_key)
          [build_message_from_definition(error, level)]
        else
          [build_fallback_message(error, level)]
        end
      end

      # Builds error messages from an error collection
      #
      # @param [Hash] errors
      # @param [Symbol] level
      #
      # @return [Array<Hash>]
      def build_errors_from_collection(errors, level)
        errors.map do |key, description|
          {
            level: level,
            key: key,
            dsc: description
          }
        end
      end

      # Builds an error message using its definition
      #
      # @param [Exception] error
      # @param [Symbol] level
      #
      # @return [Hash]
      def build_message_from_definition(error, level)
        {
          level: level,
          key: error.error_key,
          dsc: error_message(error)
        }.merge(additional_message_attributes(error))
      end

      # Builds a fallback error message when no definition is available
      #
      # @param [Exception] error
      # @param [Symbol] level
      #
      # @return [Hash]
      def build_fallback_message(error, level)
        {
          level: level,
          key: error.class.name,
          dsc: error.message
        }
      end

      # Returns the message text for an error
      #
      # It first tries to retrieve the message from the error definition.
      # If no definition is found or the text is blank, it falls back to
      # the error's message attribute.
      #
      # @param [Exception] error
      #
      # @return [String]
      def error_message(error)
        definition = error_definition(error)

        if definition && present?(definition.text)
          definition.text
        else
          error.message
        end
      end

      # Returns additional attributes defined for the error message
      #
      # @param [Exception] error
      #
      # @return [Hash]
      def additional_message_attributes(error)
        definition = error_definition(error)
        return {} unless definition

        definition.fields.each_with_object({}) do |field, attrs|
          attrs[field.name] = error.send(field.name)
        end
      end

      # Returns the error definition
      #
      # If the error does not respond to :error_key, nil will be returned.
      #
      # @param [Exception] error
      #
      # @return [SDoc::Definitions::Message, nil]
      def error_definition(error)
        @definition_reader.message_definition(
          error.class.name,
          SDoc::Definitions::Message::ERROR_LEVEL
        )
      end

      # Returns a suitable HTTP status code for the given error
      #
      # If the error responds to :errors, HTTP 409 is returned.
      # If the error has a message definition, its associated status code is used.
      # Otherwise HTTP 500 is returned.
      #
      # @param [Exception] exception
      #
      # @return [Integer]
      def status_code(exception)
        return HTTP_STATUS_CODE_CONFLICT if exception.respond_to?(:errors)

        message = error_definition(exception)
        message ? message.status_code : HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR
      end

      # Avoid ActiveSupport dependency
      def present?(value)
        !value.nil? && !value.to_s.strip.empty?
      end
    end
  end
end
