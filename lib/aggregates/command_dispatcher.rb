# frozen_string_literal: true

require 'singleton'

module Aggregates
  class CommandDispatcher
    include Singleton

    def process_commands(*commands)
      commands.each do |command|
        process_command command
      end
    end

    def process_command(command)
      validate! command
      send_command_to_processors command
      store_command command
    end

    private

    def validate(command)
      case command.validate
      in Failure(result)
        result.errors.to_h
      else
        nil
      end
    end

    def validate!(command)
      errors = validate(command)
      raise CommandValidationError, errors unless errors.nil?
    end

    def send_command_to_processors(command)
      Configuration.instance.command_processors do |command_processor|
        command_processor.process_command command
      end
    end

    def store_command(command)
      Configuration.instance.store_command command
    end
  end
end
