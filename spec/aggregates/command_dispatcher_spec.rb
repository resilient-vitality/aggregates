# frozen_string_literal: true

require 'spec_helper'

describe Aggregates::CommandDispatcher do
  context 'when validating a command' do
    it 'raises an error if the command is invalid' do
      # TODO!
    end
  end

  context 'when checking if the command should be procesed' do
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
  end
end
