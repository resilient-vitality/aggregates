# frozen_string_literal: true

module Aggregates
  # The CommandDispatcher is effectively a router of incoming commands to CommandProcessors that are responsible
  # for handling them appropriately. By convention, you likely will not need to interact with it directly, instead
  # simply call Aggregates.process_command or Aggregates.process_commands.
  class CommandDispatcher
    def initialize(command_processors, command_filters)
      @command_processors = command_processors
      @command_filters = command_filters
    end

    # Takes a single command and processes it. The command will be validated through it's contract, sent to command
    # processors and finally stored with the configured StorageBackend used for messages.
    def execute_command(execution)
      return false unless should_process? execution

      send_to_processors(execution)
      true
    end

    private

    def should_process?(execution)
      # Each command processor is going to give a true/false value for itself.
      # So if they all allow it, then we can return true. Else false.
      @command_filters.all? do |command_filter|
        command_filter.allow?(execution)
      end
    end

    def send_to_processors(execution)
      @command_processors.each do |command_processor|
        command_processor.process(execution)
      end
    end
  end
end
