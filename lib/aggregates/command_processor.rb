# frozen_string_literal: true

module Aggregates
  # A command processor is a type that correlates commands to operations on an aggregate root.
  class CommandProcessor
    include MessageProcessor
    include WithAggregateHelpers

    def process_command(command)
      handle_message command
    end
  end
end
