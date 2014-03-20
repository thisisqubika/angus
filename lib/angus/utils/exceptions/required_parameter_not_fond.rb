module Angus
  class RequiredParameterNotFound < StandardError

    attr_accessor :not_found_parameters

    def initialize(not_found_parameters)
      @not_found_parameters = not_found_parameters
    end

    def error_key
      'TODO define'
    end

    def message
      @not_found_parameters.map(&:name).join(', ')
    end

  end
end