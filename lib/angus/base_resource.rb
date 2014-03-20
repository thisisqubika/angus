require 'yaml'

module Angus
  class BaseResource

    attr_reader :request, :params

    def initialize(request, params, operation)
      @request   = request
      @params    = params
      @operation = operation
    end

    def run_validations!
      ParamsValidator.new(@operation).valid?(@params)
    end

  end
end