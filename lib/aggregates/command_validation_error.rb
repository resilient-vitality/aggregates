# frozen_string_literal: true

module Aggregates
  # Wraps a hash of errors when validating a command as an Exception.
  class CommandValidationError < StandardError
    attr_reader :errors

    def initialize(errors, msg = nil)
      super(msg)

      @errors = errors
    end
  end
end
