# frozen_string_literal: true

module Aggregates
  # The StorageBackend class is responsible for providing an interface for storing Domain messages
  # such as events and commands.
  class StorageBackend
    def store_event(_event)
      raise NotImplementedError
    end

    def store_command(_command)
      raise NotImplementedError
    end

    def load_events_by_aggregate_id(_aggregate_id)
      raise NotImplementedError
    end

    def load_commands_by_aggregate_id(_aggregate_id)
      raise NotImplementedError
    end
  end
end
