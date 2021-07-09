# frozen_string_literal: true

require 'spec_helper'

describe Aggregates::EventStream do
  context 'when loading events' do
    it 'calls the storage backend for the right aggregate_id' do
      # TODO
    end
  end

  context 'when it is publishing events' do
    it 'calls each event processor with the event' do
      # TODO
    end

    it 'calls the storage backend to save the event' do
      # TODO
    end
  end
end
