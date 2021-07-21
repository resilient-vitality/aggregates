# frozen_string_literal: true

require 'spec_helper'
require 'aggregates/aggregate_repository'
require 'aggregates/command_execution'

class TestCommand < Aggregates::Command
  interacts_with Aggregates::AggregateRoot
  attribute :allow
end

class TestProcessor < Aggregates::CommandFilter
  on TestCommand do |command, _aggregate|
    command.allow
  end
end

describe Aggregates::CommandFilter do
  let(:allow_command) { TestCommand.new(aggregate_id: Aggregates.new_aggregate_id, allow: true) }
  let(:deny_command) { TestCommand.new(aggregate_id: Aggregates.new_aggregate_id, allow: false) }
  let(:repo) { Aggregates::AggregateRepository.new(Aggregates::InMemoryStorageBackend.new) }
  let(:allow_command_execution) { Aggregates::CommandExecution.new(repo, allow_command) }
  let(:deny_command_execution) { Aggregates::CommandExecution.new(repo, deny_command) }

  it 'allows the command to be processed when there are zero processors' do
    instance = described_class.new
    expect(instance.allow?(allow_command_execution)).to be true
  end

  it 'allows the command to be processed when every processor allows it' do
    instance = TestProcessor.new
    expect(instance.allow?(allow_command_execution)).to be true
  end

  it 'denies the command when at least one handler disallows it' do
    instance = TestProcessor.new
    expect(instance.allow?(deny_command_execution)).to be false
  end
end
