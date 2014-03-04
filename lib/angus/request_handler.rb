require 'angus-router'

require_relative 'response'
require_relative 'responses'
require_relative 'middleware/exception_handler'
require_relative 'exceptions'
require_relative 'base_proxy'

module Angus
  class RequestHandler

    include Responses

    DEFAULT_RENDER = :json

    attr_reader :middleware

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
      inner_app = BaseProxy.new(self, lambda { @definitions })

      @app ||= @middleware.reverse.inject(inner_app) do |app, middleware|
        klass, args, block = middleware

        app.class.send(:define_method, :base_middleware) do
          inner_app
        end

        klass.new(app, *args, &block)
      end
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

    # TODO add more formats in the future.
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
      return if @middleware.map(&:first).include?(middleware)

      @middleware << [middleware, args, block]
    end

    def use_before(klass, middleware, *args, &block)
      return if @middleware.map(&:first).include?(middleware)
      index = @middleware.map(&:first).index(klass) or raise MiddlewareNotFound.new(middleware)

      @middleware.insert(index, [middleware, args, block])
    end

    def use_after(klass, middleware, *args, &block)
      return if @middleware.map(&:first).include?(middleware)
      index = @middleware.map(&:first).index(klass) or raise MiddlewareNotFound.new(middleware)

      @middleware.insert(index + 1, [middleware, args, block])
    end

    def disuse(middleware)
      index = @middleware.map(&:first).index(middleware) or raise MiddlewareNotFound.new(middleware)

      @middleware.delete_at(index)
    end

  end
end