# frozen_string_literal: true

require 'singleton'

module Aggregates
  class Configuration
    include Singleton

    attr_reader :command_processors, :event_processors, :storage_backend

    def initialize
      @command_processors = []
      @event_processors = []
      @storage_backend = InMemoryStorageBackend.new
    end

    def store_with(storage_backend)
      @storage_backend = storage_backend
    end

    def process_events_with(event_processor)
      @event_processors << event_processor
    end

    def process_commmands_with(command_procesor)
      @command_processors << command_procesor
    end
  end
end
