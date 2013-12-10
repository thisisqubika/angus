module Angus
  class DefinitionReader

    attr_reader :definitions

    def initialize(definitions = nil)
      @definitions = definitions || SDoc::DefinitionsReader.service_definition('definitions')
    end

    def message_definition(key, level)
      message = definitions.messages.find { |name, definition|
        name == key.to_s && definition.level.downcase == level.downcase
      }

      message.last if message
    end

  end
end