# frozen_string_literal: true

require 'spec_helper'

class CommandDispatcherTestCommand < Aggregates::Command
  attr_accessor :body

  validates_length_of :body, minimum: 10
end

class CommandDispatcherTestFilter < Aggregates::CommandFilter

end

describe Aggregates::CommandDispatcher do
  context 'when validating a command' do
    it 'raises an error if the command is invalid' do
      args = { aggregate_id: Aggregates.new_aggregate_id, body: 'short' }
      command = CommandDispatcherTestCommand.new args
      expect { described_class.instance.process_command(command) }.to raise_exception Aggregates::CommandValidationError
    end
  end

  context 'when checking if the command should be processed' do
    it 'returns false if it should not be processed' do
      # TODO
    end
  end

  context 'When executing an accepted command' do
    it 'sends the command to all command processors' do
      # TODO
    end

    it 'sends the command to the storage backend' do
      # TODO
    end

    it 'returns true' do
      # TODO
    end
  end
end
