require 'erb'
require 'thor'
require 'thor/actions'

module Angus
  class Generator < Thor
    include Thor::Actions

    RESOURCES_DIR   = 'resources'
    DEFINITIONS_DIR = 'definitions'
    SERVICES_DIR    = 'services'

    NEW_APP_DIRECTORIES = %W(#{DEFINITIONS_DIR} #{RESOURCES_DIR} #{SERVICES_DIR})

    NEW_APP_FILES = %w(
      Gemfile
      config.ru.erb
      services/service.rb.erb
      definitions/messages.yml
      definitions/representations.yml
      definitions/service.yml.erb
    )

    FILE_MAPPINGS = {
      'services/service.rb.erb' => -> command, app_name { File.join(SERVICES_DIR, "#{command.underscore(command.classify(app_name))}.rb") },
      'resources/resource.rb.erb' => -> command, name { "#{command.underscore(command.classify(name))}.rb" },
      'definitions/operations.yml.erb' => -> command, _ { File.join(command.resource_name, 'operations.yml') }
    }

    no_commands do
      def new_service(name)
        app_name(name)

        empty_directory(app_name)

        NEW_APP_DIRECTORIES.each do |directory|
          empty_directory(File.join(app_name, directory))
        end

        NEW_APP_FILES.each do |file|
          if is_erb?(file)
            copy_erb_file(file, app_name)
          else
            copy_file(file, File.join(app_name, file))
          end
        end
      end

      def resource(name)
        resource_name(name)
        resource_actions(options[:actions])

        empty_directory(RESOURCES_DIR)
        empty_directory(DEFINITIONS_DIR)

        copy_erb_file('resources/resource.rb.erb', resource_name, RESOURCES_DIR)
        copy_erb_file('definitions/operations.yml.erb', resource_name, DEFINITIONS_DIR)
        insert_into_services("    register :#{resource_name}\n")
      end

      def app_name(name = nil)
        if name.nil?
          @app_name
        else
          @app_name = name
        end
      end

      def resource_name(name = nil)
        if name.nil?
          @resource_name
        else
          @resource_name = name
        end
      end

      def resource_actions(actions = nil)
        if actions.nil?
          @resource_actions || []
        else
          @resource_actions = actions
        end
      end

      def classify(string)
        string.sub(/^[a-z\d]*/) { $&.capitalize }.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
      end

      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!('-', '_')
        word.downcase!
        word
      end
    end

    private

    def is_erb?(file)
      file.end_with?('.erb')
    end

    def copy_erb_file(file, name, base_path = nil)
      base_path = name if base_path.nil?

      tmp_file = Tempfile.new(File.basename(file))

      source = File.expand_path(find_in_source_paths(file.to_s))
      content  = ERB.new(File.binread(source)).result(binding)

      File.open(tmp_file.path, 'w') { |f| f << content }
      tmp_file.close

      copy_file(tmp_file.path, File.join(base_path, filename_resolver(file, name)))
    end

    def insert_into_services(content)
      config = {}
      config.merge!(:after => /def configure\n|def configure .*\n/)

      file = Dir[File.join(Dir.pwd, SERVICES_DIR, '*.*')].first

      insert_into_file(file, *([content] << config))
    end

    def filename_resolver(file, app_name)
      if FILE_MAPPINGS[file].nil?
        file.gsub('.erb', '')
      else
        FILE_MAPPINGS[file].call(self, app_name)
      end
    end

  end
end

Angus::Generator.source_root(File.join(File.dirname(File.expand_path(__FILE__)), 'generator',
                                       'templates'))