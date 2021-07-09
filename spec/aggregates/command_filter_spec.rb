# frozen_string_literal: true

require 'spec_helper'

describe Aggregates::CommandFilter do
  it 'allows the command to be processed when there are zero processors' do
    instance = described_class.new
    command = Aggregates::Command.new(aggregate_id: Aggregates.new_aggregate_id)
    expect(instance.allow?(command)).to be true
  end

  it 'allows the commmand to be processed when every processor allows it' do
  end

  it 'denies it when at least one handler denies the method' do
  end
end
