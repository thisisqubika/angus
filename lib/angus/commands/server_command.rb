module Angus
  class ServerCommand < Thor::Group

    def server
      command_processor.run('rackup', verbose: false)
    end

    private

    def command_processor
      @command_processor ||= Angus::CommandProcessor.new
    end

  end
end

Angus::AngusCommand.register(Angus::ServerCommand, 'server', 'server', 'Run the angus server')