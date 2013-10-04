require_relative 'response'
require_relative 'responses'

module Angus
  class RequestHandler

    include Responses

    DEFAULT_RENDER = :json

    attr_reader :env, :request, :response, :params

    def initialize
      @router = Picasso::Router.new
    end

    def router
      @router
    end

    def call(env)
      begin
        @env      = env
        @response = Response.new

        router.route(env)
      rescue Picasso::Router::NotImplementedError
        @response.status = HTTP_STATUS_CODE_NOT_FOUND

        render({'message' => 'page not found'}, {format: :json})
      end

      @response.finish
    end

    # TODO ver multiples formatos en el futuro
    def render(content, options = {})
      format = options[:format] || DEFAULT_RENDER
      case(format)
        when :html
          HtmlRender.render(@response, content)
        when :json
          JsonRender.render(@response, content)
        else
          raise 'Unknown render format'
      end
    end

    # TODO ver esto en el futuro
    # Use the specified Rack middleware
    def use(middleware, *args, &block)
      @prototype = nil
      @middleware << [middleware, args, block]
    end

  end
end