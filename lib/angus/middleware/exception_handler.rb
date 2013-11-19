require_relative '../definition_reader'
require_relative '../responses'
require_relative '../status_codes'

module Angus
  module Middleware
    class ExceptionHandler
      include Angus::StatusCodes

      def initialize(app)
        @app = app
        @definition_reader = Angus::DefinitionReader.new
      end

      def call(env)
        dup.call!(env)
      end

      def call!(env)
        @app.call(env)
      rescue Exception => exception
        [
          status_code(exception),
          { 'Content-Type' => 'application/json' },
          [build_error_response(exception)]
        ]
      end

      private

      # Returns the error definition.
      #
      # If the error does not responds to error_key nil will be returned, see EvolutionError.
      #
      # @param [#error_key] error An error object
      #
      # @return [Hash]
      def error_definition(error)
        error_key = error.class.name

        @definition_reader.message_definition(error_key, SDoc::Definitions::Message::ERROR_LEVEL)
      end

      # Returns a suitable HTTP status code for the given error
      #
      # If error param responds to #errors, then #{HTTP_STATUS_CODE_CONFLICT} will be returned.
      #
      # If error param responds to #error_key, then the status_code associated
      #  with the message will be returned.
      #
      # @param [#errors, #error_key] exception An error object
      #
      # @return [Integer] HTTP status code
      def status_code(exception)
        if exception.respond_to?(:errors)
          return HTTP_STATUS_CODE_CONFLICT
        end

        message = error_definition(exception)

        if message
          message.status_code
        else
          HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR
        end
      end

      # Returns an array of messages errors to be sent in an operation response
      #
      # If {error} respond_to? :errors then the method returns one error message
      #   for each one.
      #
      # Each message returned is a hash with:
      #  - level
      #  - key
      #  - description
      #
      # @param [Exception] error The error to be returned
      #
      # @return [Array] an array of messages
      def messages_from_error(error, level = :error)
        messages = []

        if error.respond_to?(:errors)
          error.errors.each do |key, description|
            messages << {:level => level, :key => key, :dsc => description}
          end
        elsif error.respond_to?(:error_key)
          messages << {:level => level, :key => error.error_key,
                       :dsc => error_message(error)}
        else
          messages << {:level => level, :key => error.class.name, :dsc => error.message}
        end

        messages
      end

      # Returns the message for an error.
      #
      # It first tries to get the message from text attribute of the error definition
      #   if no definition is found or if the text attribute is blank it the returns the error
      #   message attribute.
      #
      # @param [Exception] error The error to get the message for.
      #
      # @return [String] the error message.
      def error_message(error)
        error_definition = error_definition(error)

        if error_definition && !error_definition.text.blank?
          error_definition.text
        else
          error.message
        end
      end

      # Builds a service error response
      def build_error_response(error)
        error_messages = messages_from_error(error)

        JsonRender.convert(:status => :error, :messages => error_messages)
      end

    end
  end
end