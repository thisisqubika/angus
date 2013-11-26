require 'angus-router'

require_relative 'response'
require_relative 'responses'
require_relative 'middleware/exception_handler'

module Angus
  class RequestHandler

    include Responses

    DEFAULT_RENDER = :json

    def initialize
      @router = Angus::Router.new
      @middleware = []

      use Middleware::ExceptionHandler
    end

    def router
      @router
    end

    def call(env)
      to_app.call(env)
    end

    def to_app
      inner_app = lambda { |env| self.dup.call!(env) }
      @middleware.reverse.inject(inner_app) { |app, middleware| middleware.call(app) }
    end

    def call!(env)
      begin
        response = router.route(env)
      rescue NotImplementedError
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

    def use(middleware, *args, &block)
      @middleware << lambda { |app| middleware.new(app, *args, &block) }
    end

  end
end