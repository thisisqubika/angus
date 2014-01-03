require_relative 'angus_command'

module Angus
  class ScaffoldCommand < Thor::Group

    argument :name,    desc: 'Name of the resource', type: :string
    def scaffold
      command_processor.resource(self.name, %w(create update destroy show index), {scaffold: true})
    end

    private

    def command_processor
      @command_processor ||= Angus::CommandProcessor.new
    end

  end
end

Angus::AngusCommand.register(Angus::ScaffoldCommand, 'scaffold', 'scaffold [NAME]', 'Generate a scaffold of a given model')