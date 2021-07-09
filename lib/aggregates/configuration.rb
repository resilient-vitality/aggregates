# frozen_string_literal: true

require 'singleton'

module Aggregates
  # Stores all of the items needed to dictate the exact behavior needed by
  # the application consuming the Aggregates gem.
  class Configuration
    include Singleton

    attr_reader :command_processors, :event_processors,
                :storage_backend, :command_filters

    def initialize
      @command_processors = []
      @event_processors = []
      @command_filters = []
      @storage_backend = InMemoryStorageBackend.new
    end

    def filter_commands_with(command_filter)
      @command_filters << command_filter
    end

    def store_with(storage_backend)
      @storage_backend = storage_backend
    end

    def process_events_with(event_processor)
      @event_processors << event_processor
    end

    def process_commands_with(command_processor)
      @command_processors << command_processor
    end
  end
end
