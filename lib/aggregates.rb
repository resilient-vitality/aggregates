# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module Aggregates
  def configure
    yield Configuration.instance
  end

  def new_aggregate_id
    SecureRandom.uuid.to_s
  end

  def execute_command(command)
    CommandProcessor.instance.execute_command command
  end

  def execute_commands(*commands)
    CommandProcessor.instance.execute_commands(*commands)
  end
end
