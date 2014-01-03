require 'erb'
require 'thor'
require 'thor/runner'
require 'angus'

require_relative 'command_processor'

module Angus
  class AngusCommand < ::Thor::Runner

  end
end