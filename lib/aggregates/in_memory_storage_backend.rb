# frozen_string_literal: true

module Aggregates
  # This is an extremely simple storage backend that retains all events and commands in process
  # memory. This method does not persist beyond application restarts and should generally only be
  # used in testing.
  class InMemoryStorageBackend < StorageBackend
    def initialize
      super()

      @events = {}
      @commands = {}
    end

    def store_command(command)
      commands_for_aggregate_id = load_commands_by_aggregate_id(command.aggregate_id)
      commands_for_aggregate_id << command
    end

    def store_event(event)
      events_for_aggregate_id = load_events_by_aggregate_id(event.aggregate_id)
      events_for_aggregate_id << event
    end

    def load_events_by_aggregate_id(aggregate_id)
      @events[aggregate_id] ||= []
    end

    def load_commands_by_aggregate_id(aggregate_id)
      @commands[aggregate_id] ||= []
    end
  end
end
