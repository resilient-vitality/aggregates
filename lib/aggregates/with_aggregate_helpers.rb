# frozen_string_literal: true

module Aggregates
  # Helper functions for running blocks with a specified aggregate.
  module WithAggregateHelpers
    # Class Methods to extend onto the host class.
    module ClassMethods
      def with_aggregate(type, command, &block)
        aggregate_id = command.aggregate_id
        with_aggregate_by_id(type, aggregate_id, &block)
      end

      def with_aggregate_by_id(type, aggregate_id)
        yield type.get_by_id aggregate_id
      end
    end

    def self.included(host_class)
      host_class.extend(ClassMethods)
    end
  end
end
