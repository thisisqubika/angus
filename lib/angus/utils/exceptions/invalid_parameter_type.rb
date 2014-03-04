module Angus
  class InvalidParameterType < StandardError

    def initialize(field, param)
      @field = field
      @param = param
    end

    def error_key
      'TODO define'
    end

    def message
      'TODO define'
    end

  end
end