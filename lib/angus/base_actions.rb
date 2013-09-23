module Angus
  module BaseActions

    def discover_paths
      {
        'doc' => doc_path,
        'api' => api_path
      }
    end

    def register_base_routes
      router.on(:get, '/') do
        render discover_paths
      end

      router.on(:get, base_path) do
        render discover_paths
      end

      router.on(:get, doc_path) do
        render(Picasso::SDoc::HtmlFormatter.format_service(@definitions), format: :html)
      end
    end

    def doc_path
      "#{base_path}/doc"
    end

    def api_path
      "#{base_path}/api"
    end

  end
end