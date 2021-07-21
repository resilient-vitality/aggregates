# frozen_string_literal: true

require_relative './event_stream'

module Aggregates
  # Uses the storage backend to store load aggregates.
  class AggregateRepository
    def initialize(storage_backend)
      @storage_backend = storage_backend
    end

    def load_aggregate(type, id, at: nil)
      event_stream = create_aggregate_event_stream(type, id)
      aggregate = type.new(id, event_stream)
      replay_events_on_aggregate(aggregate, event_stream, at)
      aggregate
    end

    private

    def create_aggregate_event_stream(type, id)
      EventStream.new(@storage_backend, type, id)
    end

    def replay_events_on_aggregate(aggregate, event_stream, at)
      events = event_stream.load_events ending_at: at
      events.each do |event|
        aggregate.process_event(event)
      end
    end
  end
end
