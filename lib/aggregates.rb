# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

# A helpful library for building CQRS and Event Sourced Applications.
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

  def self.audit(type, aggregate_id)
    Auditor.new type, aggregate_id
  end
end
