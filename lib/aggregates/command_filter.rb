# frozen_string_literal: true

module Aggregates
  # Applies filters to commands to decouple filtering logic from the CommandProcessor.
  class CommandFilter
    include MessageProcessor
    include WithAggregateHelpers

    def allow?(command)
      handle_message(command).all?
    end
  end
end
