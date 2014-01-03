require 'erb'
require 'thor'
require 'thor/actions'
require_relative '../generator/thor/new_project'
require_relative '../generator/thor/resource'

module Angus
  class CommandProcessor < Thor
    include Thor::Actions

    RESOURCES_DIR   = 'resources'
    DEFINITIONS_DIR = 'definitions'
    SERVICES_DIR    = 'services'

    no_tasks do
      def new_service(name, config = {})
        new_project(name, config)
      end

      def new_resource(name, actions, config = {})
        resource(name, actions, config)
      end

    end
  end
end

Angus::CommandProcessor.source_root(File.join(File.dirname(File.expand_path(__FILE__)), '..', 'generator', 'templates'))