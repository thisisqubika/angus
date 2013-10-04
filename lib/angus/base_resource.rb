require 'yaml'

module Angus
  class BaseResource

    attr_reader :request, :params

    def initialize(request, params)
      @request = request
      @params = params
    end

  end
end