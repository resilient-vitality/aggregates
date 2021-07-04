# frozen_string_literal: true

module Aggregates
  module Dynamoid
    class DynamoidStorageBackend < StorageBackend
      def store_event(_event)
        super
      end

      def store_command(_command)
        super
      end

      def load_events_by_aggregate_id(_aggregate_id)
        super
      end
    end
  end
end
