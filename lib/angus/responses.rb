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
    def build_success_response(elements = {}, optional_fields = [], messages = [])
      extra_response_attributes = elements[:extra_response_attributes]

      if extra_response_attributes && optional_fields
        optional_fields.reject! do |optional_field|
          extra_response_attributes.any? { |erp| optional_field.include?(erp) }
        end
      end

      elements = remove_optional_data(elements, optional_fields)

      elements.delete(:extra_response_attributes)

      elements = {
        status: :success
      }.merge(elements)

      elements[:messages] = messages unless messages.empty?

      json(elements)
    end

    # Builds a success response with the received data
    #
    # @param [Hash] data the hash to be returned in the response
    # @param [Array] attributes the attributes that will be returned
    # @param [Message, Symbol, String] messages A list of messages, or message keys
    def build_data_response(data, attributes, messages = [])
      marshalled_data = Angus::Marshalling.marshal_object(data, attributes)

      optional_fields = attributes.select do |attr|
        attr.is_a?(Hash) && attr.key?(:optional_fields)
      end.first.values.flatten

      messages = build_messages(Angus::SDoc::Definitions::Message::INFO_LEVEL, messages)

      build_success_response(marshalled_data, optional_fields, messages)
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
      JSON(element, ascii_only: true)
    end

    def remove_optional_data(data, optional_keys)
      if optional_keys
        optional_keys.each do |key_path|
          keys_to_remove = key_path.split('.')

          remove_data(data, keys_to_remove)
        end

        clean_up_empty_data(data, optional_keys)
      else
        data
      end
    end

    def remove_data(data, keys)
      current_key = keys.shift

      if data.is_a?(Array)
        data.each { |item| remove_data(item, keys.dup) }
      elsif data.is_a?(Hash) && data.key?(current_key.to_sym)
        if keys.empty?
          data.delete(current_key.to_sym)
        else
          if data[current_key.to_sym].is_a?(Array)
            data[current_key.to_sym].each { |item| remove_data(item, keys.dup) }
          else
            remove_data(data[current_key.to_sym], keys)
          end
        end
      end
    end

    def clean_up_empty_data(data, keys)
      if data.is_a?(Hash)
        data.each do |key, value|
          if keys.include?(key.to_s)
            if value.is_a?(Hash)
              clean_up_empty_data(value, keys)

              data.delete(key) if value.empty?
            elsif value.is_a?(Array)
              value.each { |item| clean_up_empty_data(item, keys) }

              data.delete(key) if value.empty?
            end
          end
        end
      elsif data.is_a?(Array)
        data.each { |item| clean_up_empty_data(item, keys) }
      end
    end
  end
end
