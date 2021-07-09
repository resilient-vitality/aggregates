# frozen_string_literal: true

require 'spec_helper'

class TestCommand < Aggregates::Command
  attribute :allow, Aggregates::Types::Bool.default(true)
end

class TestProcessor < Aggregates::CommandFilter
  on TestCommand, &:allow
end

describe Aggregates::CommandFilter do
  it 'allows the command to be processed when there are zero processors' do
    instance = described_class.new
    command = TestCommand.new(aggregate_id: Aggregates.new_aggregate_id)
    expect(instance.allow?(command)).to be true
  end

  it 'allows the command to be processed when every processor allows it' do
    command = TestCommand.new(aggregate_id: Aggregates.new_aggregate_id)
    instance = TestProcessor.new
    expect(instance.allow?(command)).to be true
  end

  it 'denies the command when at least one handler disallows it' do
    command = TestCommand.new(aggregate_id: Aggregates.new_aggregate_id, allow: false)
    instance = TestProcessor.new
    expect(instance.allow?(command)).to be false
  end
end
