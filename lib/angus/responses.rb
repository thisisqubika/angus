require 'angus/sdoc'

require_relative 'status_codes'

module Angus
  module Responses
    include Angus::StatusCodes

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
        build_message(message, level)
      end
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

      { :level => level, :key => key, :dsc => description }
    end

    def get_message_definition(key, level)
      message = @definitions.messages.find { |name, definition|
        name == key.to_s && definition.level.downcase == level.downcase
      }

      message.last if message
    end

    # Serializes +element+ as json
    def json(element)
      JSON(element, :ascii_only => true)
    end

  end
end
