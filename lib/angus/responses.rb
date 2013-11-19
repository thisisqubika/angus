require 'angus/sdoc'

require_relative 'status_codes'

module Angus
  module Responses
    include Angus::StatusCodes

    # Returns the error definition.
    #
    # If the error does not responds to error_key nil will be returned, see EvolutionError.
    #
    # @param [#error_key] error An error object
    #
    # @return [Hash]
    def get_error_definition(error)
      error_key = error.class.name

      get_message_definition(error_key, Angus::SDoc::Definitions::Message::ERROR_LEVEL)
    end

    def get_message_definition(key, level)
      message = @definitions.messages.find { |name, definition|
        name == key.to_s && definition.level.downcase == level.downcase
      }

      message.last if message
    end

    # Builds a service success response
    #
    # @param [Hash<Symbol, Object>] messages Elements to be sent in the response
    # @param [Array<ResponseMessage] messages Messages to be sent in the response
    #
    # @return [String] JSON response
    def build_success_response(elements = {}, messages = [])
      elements = {
        :status => :success,
      }.merge(elements)

      unless messages.empty?
        elements[:messages] = messages
      end

      json(elements)
    end

    # Builds a ResponseMessage object
    #
    # @param [#to_s] key Message key
    # @param [#to_s] level Message level
    # @param [*Object] params Objects to be used when formatting the message description
    #
    # @raise [NameError] when there's no message for the given key and level
    #
    # @return [ResponseMessage]
    def build_message(key, level, *params)
      message_definition = get_message_definition(key, level)

      unless message_definition
        raise NameError.new("Could not found message with key: #{key}, level: #{level}")
      end

      description = if message_definition.text
                      message_definition.text % params
                    else
                      message_definition.description
                    end

      Angus::SDoc::Definitions::Message

      message = Angus::SDoc::Definitions::Message.new
      message.key = key
      message.level = level
      message.description = description

      message
    end

    # Builds a service success response
    def build_warning_response(error)
      error_messages = messages_from_error(error, :warning)
      build_response(:success, *error_messages)
    end

    # Builds a success response with the received data
    #
    # @param [Hash] data the hash to be returned in the response
    # @param [Array] attributes the attributes that will be returned
    # @param [Message, Symbol, String] messages A list of messages, or message keys
    def build_data_response(data, attributes, messages = [])
      marshalled_data = Angus::Marshalling.marshal_object(data, attributes)

      messages = build_messages(Angus::SDoc::Definitions::Message::INFO_LEVEL, messages)

      build_success_response(marshalled_data, messages)
    end

    # Builds a success response with no elements
    #
    # The response would include the following:
    #  - status
    #  - messages
    #
    # @param [Array<ResponseMessage>, Array<Symbol>] messages Message to be included in the response
    #
    # @return [String] JSON response
    def build_no_data_response(messages = [])
      messages = build_messages(Angus::SDoc::Definitions::Message::INFO_LEVEL, messages)

      build_success_response({}, messages)
    end

    # Builds a list of messages with the following level
    #
    # ResponseMessage objects contained in messages param won't be modified, this method
    #  only creates ResponseMessage for each Symbol in messages array
    #
    # @param [#to_s] level Messages level
    # @param [Array<ResponseMessage>, Array<Symbol>] messages
    #
    # @raise (see #build_message)
    #
    # @return [Array<ResponseMessage>]
    def build_messages(level, messages)
      (messages || []).map do |message|
        if message.kind_of?(Angus::SDoc::Definitions::Message)
          message
        else
          build_message(message, level)
        end
      end
    end

    # Sets the content_type to json and serialize +element+ as json
    def json(element)
      #content_type :json
      JSON(element, :ascii_only => true)
    end

    private
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
      error_definition = get_error_definition(error)

      if error_definition && !error_definition.text.blank?
        error_definition.text
      else
        error.message
      end
    end

    def build_response(status, *messages)
      json(:status => status, :messages => messages)
    end

  end
end
