# frozen_string_literal: true

require 'spec_helper'

describe Aggregates::AggregateRoot do
  context 'when immutable' do
    it 'fails when calling #apply' do
      # TODO
    end
  end

  context 'when replaying history' do
    it 'only applies events that happen before the up_to parameter' do
      # TODO
    end

    it 'applies all events when up_to is not specified' do
      # TODO
    end
  end

  context 'when applying events' do
    it 'increments the sequence number' do
      # TODO
    end

    it 'publishes the event on the stream' do
      # TODO
    end

    it 'calls the handlers on the event produced' do
      # TODO
    end
  end
end
