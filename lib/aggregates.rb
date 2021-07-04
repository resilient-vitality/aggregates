# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module Aggregates
  def self.configure
    yield Configuration.instance
  end

  def self.new_aggregate_id
    SecureRandom.uuid.to_s
  end

  def self.execute_command(command)
    CommandDispatcher.instance.execute_command command
  end

  def self.execute_commands(*commands)
    CommandDispatcher.instance.execute_commands(*commands)
  end

  def self.audit(aggregate_id)
    Auditor.new aggregate_id
  end
end
