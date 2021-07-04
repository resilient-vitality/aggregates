# frozen_string_literal: true

module Aggregates
  class Auditor
    def initialize(aggregate_id)
      @aggregate_id = aggregate_id
    end

    def events
      Configuration.storage_backend.load_events_by_aggregate_id(@aggregate_id)
    end

    def commands
      Configuration.storage_backend.load_commands_by_aggregate_id(@aggregate_id)
    end
  end
end
