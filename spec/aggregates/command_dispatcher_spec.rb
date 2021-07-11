# frozen_string_literal: true

require 'spec_helper'

VALID_ID = Aggregates.new_aggregate_id

class CommandDispatcherTestCommand < Aggregates::Command
  field :body

  validates_length_of :body, minimum: 10

  def self.invalid
    args = { aggregate_id: Aggregates.new_aggregate_id, body: 'short' }
    new args
  end

  def self.valid
    args = { aggregate_id: VALID_ID, body: 'shortlonglonger' }
    new args
  end
end

class CommandDispatcherTestFilter < Aggregates::CommandFilter
  def initialize(allow)
    super()
    @allow = allow
  end

  filter Aggregates::Command do |_command, _aggregate|
    @allow
  end
end

class CommandDispatcherTestProcessor < Aggregates::CommandProcessor
  attr_reader :called

  process Aggregates::Command do |_command, _aggregate|
    @called = true
  end
end

def process_valid_command
  command = CommandDispatcherTestCommand.valid
  described_class.instance.process_command(command)
end

describe Aggregates::CommandDispatcher do
  processor_one = CommandDispatcherTestProcessor.new
  processor_two = CommandDispatcherTestProcessor.new

  before do
    Aggregates.configure do |config|
      config.process_commands_with processor_one, processor_two
    end
  end

  context 'when validating a command' do
    it 'raises an error if the command is invalid' do
      command = CommandDispatcherTestCommand.invalid
      expect { described_class.instance.process_command(command) }.to raise_exception Aggregates::CommandValidationError
    end
  end

  context 'when checking if the command should be processed' do
    it 'returns false if it should not be processed' do
      Aggregates.configure do |config|
        config.filter_commands_with CommandDispatcherTestFilter.new(false)
      end
      result = process_valid_command
      expect(result).to be false
    end
  end

  context 'when executing an accepted command' do
    it 'sends the command to all command processors' do
      process_valid_command
      results = [processor_one.called, processor_two.called]
      expect(results.all?).to be true
    end

    it 'sends the command to the storage backend' do
      process_valid_command
      storage_backend = Aggregates::Configuration.instance.storage_backend
      stored_commands = storage_backend.load_commands_by_aggregate_id(VALID_ID)
      expect(stored_commands.length).to be 1
    end

    it 'returns true' do
      Aggregates.configure do |config|
        config.filter_commands_with CommandDispatcherTestFilter.new(true)
      end
      result = process_valid_command
      expect(result).to be true
    end
  end
end
