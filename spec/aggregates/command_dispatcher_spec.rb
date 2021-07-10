# frozen_string_literal: true

require 'spec_helper'

class CommandDispatcherTestCommand < Aggregates::Command
  attr_accessor :body

  validates_length_of :body, minimum: 10

  def self.invalid
    args = { aggregate_id: Aggregates.new_aggregate_id, body: 'short' }
    new args
  end

  def self.valid
    args = { aggregate_id: Aggregates.new_aggregate_id, body: 'shortlonglonger' }
    new args
  end
end

class CommandDispatcherTestFilter < Aggregates::CommandFilter
  def initialize(allow)
    super()
    @allow = allow
  end

  on Aggregates::Command do |_command|
    @allow
  end
end

class CommandDispatcherTestProcessor < Aggregates::CommandProcessor
  attr_reader :called

  on Aggregates::Command do |_command|
    @called = true
  end
end

describe Aggregates::CommandDispatcher do
  context 'when validating a command' do
    it 'raises an error if the command is invalid' do
      command = CommandDispatcherTestCommand.invalid
      expect { described_class.instance.process_command(command) }.to raise_exception Aggregates::CommandValidationError
    end
  end

  context 'when checking if the command should be processed' do
    it 'returns false if it should not be processed' do
      command = CommandDispatcherTestCommand.valid
      Aggregates.configure do |config|
        config.filter_commands_with CommandDispatcherTestFilter.new(false)
      end
      result = described_class.instance.process_command(command)
      expect(result).to be false
    end
  end

  context 'When executing an accepted command' do
    it 'sends the command to all command processors' do
      processor_one = CommandDispatcherTestProcessor.new
      processor_two = CommandDispatcherTestProcessor.new
      Aggregates.configure do |config|
        config.process_commands_with processor_one, processor_two
      end
      described_class.instance.process_command(CommandDispatcherTestCommand.valid)
      expect(processor_one.called).to be true
      expect(processor_two.called).to be true
    end

    it 'sends the command to the storage backend' do
      command = CommandDispatcherTestCommand.valid
      described_class.instance.process_command(command)
      storage_backend = Aggregates::Configuration.instance.storage_backend
      stored_commands = storage_backend.load_commands_by_aggregate_id(command.aggregate_id)
      expect(stored_commands).to contain_exactly(command)
    end

    it 'returns true' do
      command = CommandDispatcherTestCommand.valid
      Aggregates.configure do |config|
        config.filter_commands_with CommandDispatcherTestFilter.new(true)
      end
      result = described_class.instance.process_command(command)
      expect(result).to be true
    end
  end
end
