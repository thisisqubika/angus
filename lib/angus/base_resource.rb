require 'yaml'

module Angus
  class BaseResource

    attr_reader :request, :params

    #attr_reader :exception_handlers

    def initialize(request, params)
      @request = request
      @params = params
    end

    #def rescue_from(exception, options = {})
    #  @exception_handlers ||= {}
    #  @exception_handlers[exception] = options
    #end
    #
    #def handled_exceptions(exception)
    #  @exception_handlers ||= {}
    #  @exception_handlers.each do |handle_exception, options|
    #    if exception.kind_of?(handle_exception)
    #      send(options[:with], exception)
    #      return true
    #    end
    #  end
    #
    #  return false
    #end

  end
end