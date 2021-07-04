# frozen_string_literal: true

require 'singleton'

module Aggregates
  class Configuration
    include Singleton

    attr_accessor :command_processors, :event_processors, :storage_backend

    def initialize
      @command_processors = []
      @event_processors = []
      @storage_backend = nil
    end
  end
end
