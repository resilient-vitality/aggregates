# frozen_string_literal: true

module Aggregates
  class AggregateRoot < EventProcessor
    attr_reader :id

    def self.get_by_id(id)
      instance = new id
      instance.replay_history
    end

    def initialize(id)
      super()

      @id = id
      @sequence_number = 1
      @event_stream = EventStream.new id
    end

    def replay_history
      @event_stream.load_events.each do |event|
        process_event event
        @sequence_number += 1
      end
    end

    def build_event(event, params)
      default_args = { aggregate_id: @id, sequence_number: @sequence_number }
      event.new(params.merge(default_args))
    end

    def apply(event, params = {})
      event = build_event(event, params)
      @event_stream.publish event
      process_event event
      @sequence_number += 1
    end
  end
end
