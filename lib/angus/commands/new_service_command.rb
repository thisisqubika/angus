module Angus
  class NewServiceCommand < Thor::Group

    argument :name, desc: 'Name of the resource', type: :string
    def new
      command_processor.new_service(self.name)
    end

    private

    def command_processor
      @command_processor ||= Angus::CommandProcessor.new
    end

  end
end

Angus::AngusCommand.register(Angus::NewServiceCommand, 'new', 'new', 'Generate a new service')