# frozen_string_literal: true

module Aggregates
  # Applies filters to commands to decouple filtering logic from the CommandProcessor.
  class CommandFilter < CommandProcessor
    class << self
      alias filter on
    end

    def allow?(command)
      process_command(command).all?
    end
  end
end
