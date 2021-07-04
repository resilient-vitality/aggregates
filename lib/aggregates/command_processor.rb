# frozen_string_literal: true

module Aggregates
  class CommandProcessor
    include MessageProcessor

    def with_aggregate(type, command, &block)
      aggregate_id = command.aggregate_id
      with_aggregate_by_id(type, aggregate_id, &block)
    end

    def with_aggregate_by_id(type, aggregate_id)
      yield type.find_by_id aggregate_id
    end

    def process_command(command)
      handle_message command
    end
  end
end
