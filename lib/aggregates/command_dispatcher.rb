# frozen_string_literal: true

require 'singleton'

module Aggregates
  # The CommandDispatcher is effectively a router of incoming commands to CommandProcessors that are responsible
  # for handling them appropriately. By convention, you likely will not need to interact with it directly, instead
  # simply call Aggregates.process_command or Aggregates.process_commands.
  class CommandDispatcher
    include Singleton

    def initialize
      @config = Configuration.instance
    end

    # Takes a sequence of commands and executes them one at a time.
    def process_commands(*commands)
      commands.each do |command|
        process_command command
      end
    end

    # Takes a single command and processes it. The command will be validated through it's contract, sent to command
    # processors and finally stored with the configured StorageBackend used for messages.
    def process_command(command)
      validate! command
      send_command_to_processors command
      store_command command
    end

    private

    def send_command_to_processors(command)
      @config.command_processors do |command_processor|
        command_processor.process_command command
      end
    end

    def store_command(command)
      @config.storage_backend.store_command command
    end
  end
end
