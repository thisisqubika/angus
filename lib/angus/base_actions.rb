module Angus
  module BaseActions

    def discover_paths
      {
        'doc' => doc_path,
        'api' => api_path
      }
    end

    def register_base_routes
      router.on(:get, '/') do |env, params|
        response = Response.new

        render(response, discover_paths)
      end

      router.on(:get, base_path) do |env, params|
        response = Response.new

        render(response, discover_paths)
      end

      router.on(:get, doc_path) do |env, params|
        response = Response.new

        if params[:format] == 'json'
          render(response, Angus::SDoc::JsonFormatter.format_service(@definitions), format: :json)
        else
          language = params[:lang] || self.default_doc_language
          render(response, Angus::SDoc::HtmlFormatter.format_service(@definitions, language),
                 format: :html)
        end
      end
    end

    def doc_path
      "#{base_path}/doc/#{service_version}"
    end

    def api_path
      "#{base_path}/api/#{service_version}"
    end

  end
end