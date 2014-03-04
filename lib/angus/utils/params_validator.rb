require_relative 'exceptions/required_parameter_not_fond'
require_relative 'exceptions/invalid_parameter_type'

module Angus
  class ParamsValidator

    DEFAULT_DATE_FORMAT     = '%Y-%m-%d'
    DEFAULT_DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%S%z'

    def initialize(operation)
      @operation        = operation
      @request_elements = operation.request_elements
    end

    def valid?(params)
      all_required_fields?(params)
      all_valid_types?(params)
    end

    def all_required_fields?(params)
      required_fields = @request_elements.select(&:required)

      no_found_parameters = required_fields.select {|rf| !params.include?(rf.name.to_sym) }

      unless no_found_parameters.empty?
        raise RequiredParameterNotFound.new(no_found_parameters)
      end
    end

    def all_valid_types?(params)
      @request_elements.each do |field|
        type = field.type
        method_name = "valid_#{type}?"

        if self.respond_to?(method_name)
          param = params[field.name.to_sym]

          valid = self.send(method_name, field, param)

          raise InvalidParameterType.new(field, param) unless valid
        else
          # TODO handle complex types
        end
      end
    end

    # String are all ways valid
    def valid_string?(field, param)
      true
    end

    def valid_integer?(field, param)
      !!(param =~ /^[-+]?[0-9]+$/)
    end

    def valid_decimal?(field, param)
      !!(param =~/^[-+]?([0-9]+(\.[0-9]+)?$)/)
    end

    def valid_date?(field, param)
      begin
        Date.strptime(param, DEFAULT_DATE_FORMAT)

        true
      rescue ArgumentError
        false
      end
    end

    def valid_datetime?(field, param)
      begin
        DateTime.strptime(param, DEFAULT_DATETIME_FORMAT)

        true
      rescue ArgumentError
        false
      end
    end

  end
end