# frozen_string_literal: true

require_relative './command_dispatcher'
require_relative './domain_executor'

module Aggregates
  # Defines the collection of command processors, event processors, and command filters
  # that are executed together.
  class Domain
    attr_reader :command_processors, :event_processors, :command_filters

    def initialize
      @command_processors = []
      @event_processors = []
      @command_filters = []
    end

    def process_events_with(*event_processors)
      event_processors.each do |event_processor|
        @event_processors << event_processor
      end
    end

    def process_commands_with(*command_processors)
      command_processors.each do |command_processor|
        @command_processors << command_processor
      end
    end

    def filter_commands_with(*command_filters)
      command_filters.each do |command_filter|
        @command_filters << command_filter
      end
    end

    def execute_with(storage_backend)
      DomainExecutor.new(storage_backend, self)
    end
  end
end
