# frozen_string_literal: true

module Aggregates
  # A command processor is a type that correlates commands to operations on an aggregate root.
  class CommandProcessor
    include MessageProcessor

    class << self
      alias process on
    end

    def process_command(command)
      aggregate = command.related_aggregate
      invoke_handlers(command, aggregate)
    end
  end
end
