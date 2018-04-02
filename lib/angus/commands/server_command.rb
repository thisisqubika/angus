module Angus
  class ServerCommand < Thor::Group
    include Thor::Actions

    class_option :port, desc: 'use PORT (default: 9292)', type: :string, required: false, default: '9292'
    class_option :host, desc: 'listen on HOST (default: localhost)', type: :string, required: false, default: '0.0.0.0'

    def server
      port_option = "-p #{options[:port]}" || ''
      host_option = "--host #{options[:host]}" || ''
      command_processor.run("rackup #{port_option} #{host_option}", verbose: false)
    end

    private

    def command_processor
      @command_processor ||= Angus::CommandProcessor.new
    end

  end
end

Angus::AngusCommand.register(Angus::ServerCommand, 'server', 'server', 'Run the angus server')