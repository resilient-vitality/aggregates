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
      commands.map do |command|
        process_command command
      end
    end

    # Takes a single command and processes it. The command will be validated through it's contract, sent to command
    # processors and finally stored with the configured StorageBackend used for messages.
    def process_command(command)
      command.validate!
      return false unless should_process? command

      send_to_processors command
      store command
      true
    end

    private

    def should_process?(command)
      # Each command processor is going to give a true/false value for itself.
      # So if they all allow it, then we can return true. Else false.
      @config.command_filters.all? do |command_filter|
        command_filter.allow? command
      end
    end

    def send_to_processors(command)
      @config.command_processors.each do |command_processor|
        command_processor.process_command command
      end
    end

    def store(command)
      @config.storage_backend.store_command command
    end
  end
end
