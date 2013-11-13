require 'angus-router'

require_relative 'response'
require_relative 'responses'

module Angus
  class RequestHandler

    include Responses

    DEFAULT_RENDER = :json

    attr_reader :env, :request, :response, :params

    def initialize
      @router = Angus::Router.new
    end

    def router
      @router
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      begin
        response = router.route(env)
      rescue Angus::Router::NotImplementedError
        response = Response.new
        response.status = HTTP_STATUS_CODE_NOT_FOUND

        render(response, { 'status' => 'error',
                 'messages' => [{ 'level' => 'error', 'key' => 'RouteNotFound',
                                  'dsc' => 'Invalid route' }]
               }, {format: :json})
      end

      response.finish
    end

    # TODO ver multiples formatos en el futuro
    def render(response, content, options = {})
      format = options[:format] || DEFAULT_RENDER
      case(format)
        when :html
          HtmlRender.render(response, content)
        when :json
          JsonRender.render(response, content)
        else
          raise 'Unknown render format'
        end

      response
    end

    # TODO ver esto en el futuro
    # Use the specified Rack middleware
    def use(middleware, *args, &block)
      @prototype = nil
      @middleware << [middleware, args, block]
    end

  end
end