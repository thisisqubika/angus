module Angus
  module ProxyActions

    def after_configure
      register_proxy_actions
      register_proxy_routes
    end

    def register_proxy_routes
      @definitions.proxy_operations.each do |proxy_operation|
        register_proxy_route(proxy_operation)
      end
    end

    def register_proxy_actions
      router.on(:get, File.join(doc_path, '/proxy/:service')) do |env, params|
        require 'picasso-remote'
        response = Response.new

        service = params[:service]

        remote_definition = Picasso::Remote::ServiceDirectory.service_definition(service)

        render(response, Picasso::SDoc::JsonFormatter.format_service(remote_definition),
               format: :json)
      end
    end

    def register_proxy_route(proxy_operation)
      require 'picasso-remote'

      remote_api_uri = Picasso::Remote::ServiceDirectory.api_url(proxy_operation.service_name)

      proxy_client = get_proxy_client(remote_api_uri)

      op_path = "#{api_path}#{proxy_operation.path}"

      router.on(proxy_operation.http_method.to_sym, op_path) do |env, params|
        request = Rack::Request.new(env)
        request.body.rewind
        raw_body = request.body.read

        proxy_path =  env['PATH_INFO'].gsub(api_path, '')

        status, headers, body = proxy_client.make_request(
          proxy_operation.http_method,
          proxy_path,
          env['QUERY_STRING'],
          {},
          raw_body
        )

        Response.new(body, status, headers)
      end
    end

    def self.remote_operation(service_code_name, operation_code_name)
      remote_service = Picasso::Remote::ServiceDirectory.service_definition(service_code_name)
      remote_service.operation_definition(operation_code_name)
    end

    def get_proxy_client(url)
      proxy_clients[url] ||= build_proxy_client(url)
    end

    def build_proxy_client(url)
      Angus::Remote::ProxyClient.new(url)
    end

    def proxy_clients
      @proxy_clients ||= {}
    end

  end
end