module Angus
  class HelpCommand < Thor::Group

    def help
      puts <<-HELP
        Usages:
          angus new [API NAME]  # This generate an empty angus project.

          angus demo # This generate an demo angus project.

        Examples:
          angus new great-api

          This generates a skeletal angus installation in great-api.
      HELP
    end

  end
end

Angus::AngusCommand.register(Angus::HelpCommand, 'help', 'help', 'Help using the angus command')