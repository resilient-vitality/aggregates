# frozen_string_literal: true

require 'active_model/errors'

module Aggregates
  # Commands are a type of message that define the shape and contract data that is accepted for an attempt
  # at performing a state change on a given aggregate. Essentially, they provide the api for interacting with
  # your domain. Commands should have descriptive names capturing the change they are intended to make to the domain.
  # For instance, `ChangeUserEmail` or `AddComment`.
  # :reek:MissingSafeMethod { exclude: [ validate! ] }
  class Command < DomainMessage
    class << self
      attr_reader :aggregate_type

      def interacts_with(aggregate_type)
        @aggregate_type = aggregate_type
      end
    end

    def validate!
      super
    rescue ActiveModel::ValidationError
      raise Aggregates::CommandValidationError, errors.as_json
    end

    def load_related_aggregate(aggregate_repo)
      aggregate_repo.load_aggregate(self.class.aggregate_type, aggregate_id)
    end
  end
end
