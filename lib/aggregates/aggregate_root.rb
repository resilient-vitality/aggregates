# frozen_string_literal: true

require_relative './message_processor'

module Aggregates
  # An AggregateRoot is a central grouping of domain object(s) that work to encapsulate
  # parts of our Domain or Business Logic.
  #
  # The general design of aggregate roots should be as follows:
  #   - Create functions that encapsulate different changes in your Aggregate Roots. These functions should enforce
  #   constraints on the application. Then capture state changes by creating events.
  #
  #   - Create event handlers that actually performed the state changes captured by the events
  #     made by processing commands using the above functions.
  class AggregateRoot
    include MessageProcessor

    attr_reader :id

    # Creates a new instance of an aggregate root. This should not be called directly. Instead, it should
    # be called by calling AggregateRoot.get_by_id.
    # :reek:BooleanParameter
    def initialize(id, event_stream)
      @id = id
      @sequence_number = 1
      @event_stream = event_stream
    end

    def process_event(event)
      @sequence_number += 1
      handle_message event
    end

    # Takes an event type and some parameters with which to create it. Then performs the following actions
    #   1.) Builds the final event object.
    #   2.) Processes the event locally on the aggregate.
    #   3.) Produces the event on the event stream so that is saved by the storage backend and processed
    #       by the configured processors of the given type.
    def apply(event, params = {})
      event = build_event(event, params)
      results = process_event(event)
      @event_stream.publish(event)
      results
    end

    private

    # Builds a new event from a given event type and parameter set. Includes parameters
    # needed for all events that are derived from the aggregate's state.
    def build_event(event, params)
      default_args = { aggregate_id: @id, sequence_number: @sequence_number }
      event.new(params.merge(default_args))
    end
  end
end
