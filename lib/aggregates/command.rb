# frozen_string_literal: true

require 'dry/monads'
require 'dry-validation'

module Aggregates
  # Commands are a type of message that define the shape and contract data that is accepted for an attempt
  # at performing a state change on a given aggregate. Essentially, they provide the api for interacting with
  # your domain. Commands should have descriptive names capturing the change they are intended to make to the domain.
  # For instance, `ChangeUserEmail` or `AddComment`.
  class Command < DomainMessage
    # Provides a default contract for data validation on the command itself.
    class Contract < Dry::Validation::Contract
    end

    def validate
      Contract.new.call(attributes).errors.to_h
    end

    def validate!
      errors = validate
      raise CommandValidationError, errors unless errors.length.zero?
    end
  end
end
