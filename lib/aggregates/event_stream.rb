# frozen_string_literal: true

module Aggregates
  # An EventStream is a sequence, append only sequence of events that are read when reconstructing
  # aggregates and written to when a command is processed by the aggregate.
  #
  # There is likely no need to interact with this class directly.
  class EventStream
    def initialize(aggregate_id)
      @aggregate_id = aggregate_id
      @config = Configuration.instance
    end

    def load_events
      @config.storage_backend.load_events_by_aggregate_id(@aggregate_id)
    end

    def publish(event)
      @config.event_processors.each do |event_processor|
        event_processor.process_event event
      end
      @config.storage_backend.store_event event
    end
  end
end
