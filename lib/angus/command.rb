require 'erb'
require 'thor'

require_relative 'generator'

module Angus
  class Command < Thor

    desc 'new [NAME]', 'Generate a new service'
    def new(name)
      generator.new_service(name)
    end

    desc 'resource [NAME]', 'Generate a new resource'
    method_option :actions, aliases: '-a', type: :array, desc: 'Generate the given actions for the resource'
    def resource(name)
      generator.resource(name)
    end

    private

    def generator
      @generator ||= Angus::Generator.new
    end

  end
end