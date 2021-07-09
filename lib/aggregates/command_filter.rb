# frozen_string_literal: true

module Aggregates
  class CommandFilter
    include MessageProcessor
    include WithAggregateHelpers

    def allow?(command)
      handle_message(command).all?
    end
  end
end
