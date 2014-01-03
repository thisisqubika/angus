require_relative 'helper_methods'
require_relative 'file_handler'

class Thor
  module Actions

    # Creates a new project.
    #
    # @param [String] name The name of the resource.
    # @param [Hash] config
    #
    # @example
    #
    #   new_project 'great-api'
    #
    def new_project(name, config = {})
      action NewProject.new(self, name, config)
    end

    class NewProject #:nodoc:
      include Angus::HelperMethods
      include Angus::FileHandler

      FILE_MAPPINGS = {
        'services/service.rb.erb' => -> command, app_name { File.join(Angus::CommandProcessor::SERVICES_DIR, "#{command.underscore(command.classify(app_name))}.rb") },
        'resources/resource.rb.erb' => -> command, name { "#{command.underscore(command.classify(name))}.rb" },
        'definitions/operations.yml.erb' => -> command, _ { File.join(command.resource_name, 'operations.yml') }
      }

      attr_accessor :base, :config, :app_name

      # Creates a new project.
      #
      # @param [Thor::Base] base A Thor::Base instance
      def initialize(base, name, config)
        @base, @config   = base, { :verbose => true }.merge(config)

        self.app_name = name
      end

      def invoke!
        base.empty_directory(app_name)

        new_app_directories.each do |directory|
          base.empty_directory(File.join(app_name, directory))
        end

        new_app_files.each do |file|
          if is_erb?(file)
            copy_erb_file(file, app_name)
          else
            base.copy_file(file, File.join(app_name, file))
          end
        end
      end

      def revoke!

      end

      def mapping
        FILE_MAPPINGS
      end

      protected

      def is_generating_demo?
        @config[:demo]
      end

      def new_app_directories
        [
          Angus::CommandProcessor::DEFINITIONS_DIR,
          Angus::CommandProcessor::RESOURCES_DIR,
          Angus::CommandProcessor::SERVICES_DIR
        ]
      end

      def new_app_files
        %w(
          Gemfile.erb
          config.ru.erb
          services/service.rb.erb
          definitions/messages.yml.erb
          definitions/representations.yml.erb
          definitions/service.yml.erb
        )
      end

    end
  end
end