require_relative 'helper_methods'
require_relative 'file_handler'

class Thor
  module Actions

    # Creates a new resource.
    #
    # @param [String] name The name of the resource.
    # @param [Hash] config
    #
    # @example
    #
    #   resource 'user', 'resources', 'definitions'
    #
    def resource(name, actions, config = {})
      action Resource.new(self, name, actions, config)
    end

    class Resource #:nodoc:
      include Angus::HelperMethods
      include Angus::FileHandler

      FILE_MAPPINGS = {
        'resources/resource.rb.erb' => -> command, name { "#{command.underscore(command.classify(name))}.rb" },
        'definitions/operations.yml.erb' => -> command, _ { File.join(command.underscore(command.resource_name), 'operations.yml') }
      }

      attr_accessor :base, :config, :resource_name, :actions,
                    :resource_directory, :definition_directory, :service_directory

      # Creates a new resource.
      #
      # @param [Thor::Base] base A Thor::Base instance
      def initialize(base, name, actions, config)
        @base, @config   = base, { :verbose => true }.merge(config)

        self.resource_name = pluralize(name)
        self.actions       = actions
        self.resource_directory   = File.join(Dir.pwd, Angus::CommandProcessor::RESOURCES_DIR)
        self.definition_directory = File.join(Dir.pwd, Angus::CommandProcessor::DEFINITIONS_DIR)
        self.service_directory    = File.join(Dir.pwd, Angus::CommandProcessor::SERVICES_DIR)
      end

      def invoke!
        base.empty_directory(resource_directory)
        base.empty_directory(definition_directory)

        copy_erb_file('resources/resource.rb.erb', underscore(resource_name), resource_directory)
        copy_erb_file('definitions/operations.yml.erb', underscore(resource_name), definition_directory)
        insert_into_services("    register :#{underscore(resource_name)}\n")
      end

      def revoke!

      end

      protected

      def action_description(action_name)
        action_name if is_demo?
      end

      def action_path(action_name)
        if is_demo?
          '/users'
        elsif is_scaffold?
          if action_has_id_in_path?(action_name)
            "/#{underscore(resource_name)}/:id"
          else
            "/#{underscore(resource_name)}"
          end
        end
      end

      def action_method(action_name)
        if is_demo?
          'get'
        elsif is_scaffold?
          case action_name
            when 'create'
              'post'
            when 'update'
              'put'
            when 'destroy'
              'delete'
            else
              'get'
          end
        end
      end

      def action_has_id_in_path?(action_name)
        %w[show update destroy].include?(action_name)
      end

      def response_element(action_name)
        'users' if is_demo?
      end

      def response_description(action_name)
        'Users profiles' if is_demo?
      end

      def response_required(action_name)
        true if is_demo?
      end

      def response_type(action_name)
        'user_profile' if is_demo?
      end

      def message_key(action_name)
        'ResourceNotFound' if is_demo?
      end

      def message_description(action_name)
        'Resource Not Found' if is_demo?
      end

      def mapping
        FILE_MAPPINGS
      end

      def is_scaffold?
        config[:scaffold]
      end

      def is_demo?
        config[:demo]
      end

      def insert_into_services(content)
        config = {}
        config.merge!(:after => /def configure\n|def configure .*\n/)

        file = Dir[File.join(service_directory, '*.*')].first

        base.insert_into_file(file, *([content] << config))
      end

    end
  end
end