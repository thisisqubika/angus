require_relative 'response'
require_relative 'responses'

module Angus
  class RequestHandler

    include Responses

    DEFAULT_RENDER = :json

    attr_reader :env, :request, :response, :params

    def initialize
      @router         = Picasso::Router.new
    end

    def router
      @router
    end

    def call(env)
      @env      = env
      #@request  = Rack::Request.new(env)
      @response = Response.new
      #@params   = Params.indifferent_params(@request.params)

      router.route(env)

      # TODO handle execption
      #if route_exists?(@request.request_method, @request.path)
      #  get_route_block(@request.request_method, @request.path).call
      #else
      #  @response.status = 404
      #  @response.write 'not found'
      #end

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