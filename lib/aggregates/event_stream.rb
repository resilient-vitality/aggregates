# frozen_string_literal: true

module Aggregates
  class EventStream
    def initialize(aggregate_id)
      @aggregate_id = aggregate_id
      @events_to_flush = []
    end

    def load_events
      storage_backend.load_events_by_aggregate_id(@aggregate_id)
    end

    def publish(event)
      push_event_through_processors(event)
      store(event)
    end

    private

    def storage_backend
      Configuration.instance.storage_backend
    end

    def store(event)
      storage_backend.store_event event
    end

    def self.push_event_through_processors(event)
      Configuration.instance.event_processors.each do |event_processor|
        event_processor.process_command event
      end
    end
  end
end
