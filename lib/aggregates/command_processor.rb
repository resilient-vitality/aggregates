# frozen_string_literal: true

module Aggregates
  # A command processor is a type that correlates commands to operations on an aggregate root.
  class CommandProcessor
    include MessageProcessor

    class << self
      alias process on
    end

    def process(execution)
      execution.execute_with(self)
    end
  end
end
