# frozen_string_literal: true

require 'spec_helper'

VALID_ID = Aggregates.new_aggregate_id

class CommandDispatcherTestCommand < Aggregates::Command
  interacts_with Aggregates::AggregateRoot

  attribute :body
  attribute :filter

  validates_length_of :body, minimum: 10

  def self.invalid
    args = { aggregate_id: Aggregates.new_aggregate_id, body: 'short' }
    new args
  end

  def self.valid(filter)
    args = { aggregate_id: VALID_ID, body: 'shortlonglonger', filter: filter }
    new args
  end
end

class CommandDispatcherTestFilter < Aggregates::CommandFilter
  filter Aggregates::Command do |command, _aggregate|
    !command.filter
  end
end

class CommandDispatcherTestProcessor < Aggregates::CommandProcessor
  attr_reader :called

  process Aggregates::Command do |_command, _aggregate|
    @called = true
  end
end

describe Aggregates::CommandDispatcher do
  let(:processor_one) { CommandDispatcherTestProcessor.new }
  let(:processor_two) { CommandDispatcherTestProcessor.new }
  let(:filterer) { CommandDispatcherTestFilter.new }

  let(:domain) do
    one = processor_one
    two = processor_two
    filter = filterer
    Aggregates.create_domain do
      process_commands_with one, two
      filter_commands_with filter
    end
  end

  let(:executor) do
    domain.execute_with(Aggregates::InMemoryStorageBackend.new)
  end

  def process_valid_command(filter: false)
    command = CommandDispatcherTestCommand.valid(filter)
    executor.execute_command(command)
  end

  context 'when validating a command' do
    it 'raises an error if the command is invalid' do
      command = CommandDispatcherTestCommand.invalid
      expect { executor.execute_command(command) }.to raise_exception Aggregates::CommandValidationError
    end
  end

  context 'when checking if the command should be processed' do
    it 'returns false if it should not be processed' do
      result = process_valid_command(filter: true)
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
      stored_commands = executor.storage_backend.load_commands_by_aggregate_id(VALID_ID)
      expect(stored_commands.length).to be 1
    end

    it 'returns true' do
      result = process_valid_command
      expect(result).to be true
    end
  end
end
