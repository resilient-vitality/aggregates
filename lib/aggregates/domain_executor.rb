# frozen_string_literal: true

require_relative './aggregate_repository'
require_relative './command_execution'

module Aggregates
  # Combines a storage backend and a domain in order to execute that domain.
  class DomainExecutor
    attr_reader :storage_backend, :domain

    def initialize(storage_backend, domain)
      @aggregate_repository = AggregateRepository.new(storage_backend)
      @dispatcher = CommandDispatcher.new(domain.command_processors, domain.command_filters)
      @storage_backend = storage_backend
    end

    def execute_command(command)
      command.validate!
      command_execution = CommandExecution.new(@aggregate_repository, command)
      dispatch(command_execution)
    end

    def audit(type, aggregate_id)
      Auditor.new(@storage_backend, type, aggregate_id)
    end

    private

    def store_command(command)
      @storage_backend.store_command(command)
    end

    def dispatch(command_execution)
      result = @dispatcher.execute_command(command_execution)
      store_command(command_execution.command) if result
      result
    end
  end
end
