# frozen_string_literal: true

module Aggregates
  # The Auditor captures the state of a given aggregate at time of use. It provides listings of the
  # commands and events that we executed on a given aggregate.
  class Auditor
    attr_reader :type, :aggregate_id

    def initialize(storage_backend, type, aggregate_id)
      @storage_backend = storage_backend
      @type = type
      @aggregate_id = aggregate_id
    end

    # This method creates a new instance of the aggregate root and replays the events
    # on the aggregate alone. Only events that happened prior to the time specified are
    # processed.
    def inspect_state_at(time)
      aggregate_repository = AggregateRepository.new(@storage_backend)
      aggregate_repository.load_aggregate(@type, @aggregate_id, at: time)
    end

    # Returns all stored events for a given aggregate.
    def events
      @events ||= @storage_backend.load_events_by_aggregate_id(@aggregate_id)
    end

    # Returns all commands for a given aggregate.
    def commands
      @commands ||= @storage_backend.load_commands_by_aggregate_id(@aggregate_id)
    end

    def events_processed_by(time)
      events.select { |event| event.created_at < time }
    end

    def commands_processed_by(time)
      commands.select { |event| event.created_at < time }
    end

    def commands_processed_after(time)
      commands.select { |event| event.created_at > time }
    end

    def events_processed_after(time)
      events.select { |event| event.created_at > time }
    end
  end
end
