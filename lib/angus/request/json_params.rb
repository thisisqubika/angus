require_relative '../exceptions/invalid_request_format'
require_relative '../exceptions/invalid_value_error'
require_relative '../exceptions/missing_parameter_error'

module Angus
  module Request
    module JsonParams

      # Returns the json read from the request body.
      #
      # The keys for the json are symbolized.
      #
      # @return [Hash] The parsed request body.
      #
      # @raise [InvalidRequestFormat] When an invalid json is received.
      def json_body
        @json_body ||= JSON(request.body.read, :symbolize_names => true)
      rescue JSON::ParserError
        raise Angus::Exceptions::InvalidRequestFormat
      end

      # Parses a time param.
      #
      # @param [String, Symbol] param Parameter name.
      # @param [Boolean] required When true, raises a MissingParameterError if param does not exist.
      #
      # @raise (see #get_json_param)
      # @raise [InvalidValueError] when datetime is not parseable.
      #
      # @return [Time]
      def get_json_datetime(param, required = false)
        value = get_json_param(param, required)
        Time.parse(value)
      rescue ArgumentError
        raise Angus::Exceptions::InvalidValueError.new(param, value)
      end

      # Parses an integer param.
      #
      # @param [String, Symbol] param Parameter name.
      # @param [Boolean] required When true, raises a MissingParameterError if param does not exist.
      #
      # @raise (see #get_json_param)
      # @raise [InvalidValueError] when value is not parseable.
      #
      # @return [Numeric]
      def get_json_integer(param, required = false)
        value = get_json_param(param, required)
        Integer(value)
      rescue ArgumentError
        raise Angus::Exceptions::InvalidValueError.new(param, value)
      end

      # Returns the value of a given param.
      #
      # @param [Symbol] param Param name
      #
      # @raise [MissingParameterError] when required param not found
      #
      # @return Param's value
      def get_json_param(param, required = false)
        value = json_body[param.to_sym]

        raise Angus::Exceptions::MissingParameterError.new(param) if required && value.blank?

        value
      end

      # Parses a boolean param.
      #
      # @param [String, Symbol] param Parameter name.
      # @param [Boolean] required When true, raises a MissingParameterError if param does not exist.
      #
      # @return [Boolean]
      def get_json_boolean(param, required = true)
        value = json_body[param.to_sym]


        raise Angus::Exceptions::MissingParameterError.new(param) if required && value.nil?

        value == 'true' || value == true
      end

    end
  end
end