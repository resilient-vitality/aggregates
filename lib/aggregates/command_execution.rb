# frozen_string_literal: true

module Aggregates
  # Captures the execution of a command with the aggregate at its current state.
  class CommandExecution
    attr_reader :command

    def initialize(aggregate_repo, command)
      @aggregate_repo = aggregate_repo
      @command = command
    end

    def execute_with(handler)
      handler.invoke_handlers(command, aggregate)
    end

    def aggregate
      command.load_related_aggregate(@aggregate_repo)
    end
  end
end
