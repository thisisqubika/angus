require_relative 'angus_command'

module Angus
  class DemoCommand < Thor::Group

    def demo
      project_name = 'demo'

      command_processor.new_service(project_name, {demo: true})

      command_processor.run("cd #{project_name}")
      Dir.chdir(File.join(Dir.pwd, project_name))

      command_processor.resource('user', ['index'], {demo: true})
    end

    private

    def command_processor
      @command_processor ||= Angus::CommandProcessor.new
    end

  end
end

Angus::AngusCommand.register(Angus::DemoCommand, 'demo', 'demo [NAME]', 'Generate an empty angus project')