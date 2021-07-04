# frozen_string_literal: true

module Aggregates
  class CommandValidationError < StandardError
    attr_reader :errors

    def initialize(errors, msg = nil)
      super(msg)

      @errors = errors
    end
  end
end
