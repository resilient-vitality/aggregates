# frozen_string_literal: true

module Aggregates
  # An EventStream is a sequence, append only sequence of events that are read when reconstructing
  # aggregates and written to when a command is processed by the aggregate.
  #
  # There is likely no need to interact with this class directly.
  class EventStream
    def initialize(storage_backend, event_processors, aggregate_id)
      @storage_backend = storage_backend
      @event_processors = event_processors
      @aggregate_id = aggregate_id
    end

    def load_events(ending_at: nil)
      events = @storage_backend.load_events_by_aggregate_id(@aggregate_id)
      events = events.select { |event| event.created_at <= ending_at } if ending_at.present?
      events
    end

    def publish(event)
      send_to_event_processors(event)
      store_event(event)
    end

    private

    def send_to_event_processors(event)
      @event_processors.each do |event_processor|
        event_processor.process_event(event)
      end
    end

    def store_event(event)
      @storage_backend.store_event(event)
    end
  end
end
