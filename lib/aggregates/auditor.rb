# frozen_string_literal: true

module Aggregates
  # The Auditor captures the state of a given aggregate at time of use. It provides listings of the
  # commands and events that we executed on a given aggregate.
  class Auditor
    def initialize(aggregate_id)
      @aggregate_id = aggregate_id
    end

    # Returns all stored events for a given aggregate.
    def events
      @events ||= Configuration.storage_backend.load_events_by_aggregate_id(@aggregate_id)
    end

    # Returns all commands for a given aggregate.
    def commands
      @commands ||= Configuration.storage_backend.load_commands_by_aggregate_id(@aggregate_id)
    end
  end
end
