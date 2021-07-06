# frozen_string_literal: true

module Aggregates
  # The Auditor captures the state of a given aggregate at time of use. It provides listings of the
  # commands and events that we executed on a given aggregate.
  class Auditor
    attr_reader :type, :aggregate_id

    def initialize(type, aggregate_id)
      @type = type
      @aggregate_id = aggregate_id
    end

    # This method creates a new instance of the aggregate root and replays the events
    # on the aggregate alone. Only events that happened prior to the time specified are
    # processed.
    def inspect_state_at(time)
      aggregate = @type.new @aggregate_id, mutable: false
      aggregate.replay_history up_to: time
      aggregate
    end

    # Returns all stored events for a given aggregate.
    def events
      @events ||= Configuration.storage_backend.load_events_by_aggregate_id(@aggregate_id)
    end

    # Returns all commands for a given aggregate.
    def commands
      @commands ||= Configuration.storage_backend.load_commands_by_aggregate_id(@aggregate_id)
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
