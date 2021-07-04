# frozen_string_literal: true

require 'dry/monads'
require 'dry-validation'

module Aggregates
  class Command < DomainMessage
    # Provides a default contract that requires and aggregate_id
    # to be specified.
    class Contract < Dry::Validation::Contract
    end

    # Takes the current state of the command and calls the contract
    # supplied on it. Returns a monad with the validation results.
    def validate
      Contract.new.call(attributes).to_monad
    end
  end
end
