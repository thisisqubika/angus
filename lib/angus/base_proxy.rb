module Angus

  class BaseProxy

    def initialize(request_handler, definition_block)
      @request_handler = request_handler
      @definition_block = definition_block
    end

    def call(env)
      @request_handler.dup.call!(env)
    end

    def definitions
      @definition_block.call
    end

  end

end