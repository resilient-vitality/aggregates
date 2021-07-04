# frozen_string_literal: true

module Aggregates
  class InMemoryStorageBackend < StorageBackend
    def initialize
      super()

      @events = []
      @commands = []
    end

    def store_command_command(command)
      @commands << command
    end

    def store_event(event)
      @events << event
    end

    def load_events_by_aggregate_id(aggregate_id)
      events.select { |event| event.aggregate_id == aggregate_id }
    end
  end
end
