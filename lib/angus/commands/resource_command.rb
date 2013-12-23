module Angus
  class ResourceCommand < Thor::Group

    argument :name,    desc: 'Name of the resource', type: :string
    argument :actions, desc: 'Actions to be generated', type: :array, optional: true
    def resource
      command_processor.new_resource(self.name, self.actions)
    end

    private

    def command_processor
      @command_processor ||= Angus::CommandProcessor.new
    end

  end
end

Angus::AngusCommand.register(Angus::ResourceCommand, 'resource', 'resource [NAME] [ACTIONS]', 'Generate a new resource')