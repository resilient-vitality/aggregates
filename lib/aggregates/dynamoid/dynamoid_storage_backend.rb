# frozen_string_literal: true

# rubocop:disable Style/Documentation

module Aggregates
  # rubocop:enable Style/Documentation
  begin
    require 'dynamoid'

    # Extensions to the Aggregates gem that provide message storage on DynamoDB.
    module Dynamoid
      # Stores events in DynamoDB using `Dynamoid`
      class DynamoEventStore
        include ::Dynamoid::Document

        field :aggregate_id
        field :sequence_number, :integer
        field :data

        table name: :events, hash_key: :aggregate_id, range_key: :sequence_number, timestamps: true

        def self.store!(event, data)
          args = { aggregate_id: event.aggregate_id, sequence_number: event.sequence_number, data: data }
          event = new args
          event.save!
        end
      end

      # Stores commands in DynamoDB using `Dynamoid`
      class DynamoCommandStore
        include ::Dynamoid::Document

        field :aggregate_id
        field :data

        table name: :commands, hash_key: :aggregate_id, range_key: :created_at, timestamps: true

        def self.store!(command, data)
          args = { aggregate_id: command.aggregate_id, data: data }
          command = new args
          command.save!
        end
      end

      # Stores messages on DynamoDB using the dynamoid gem.
      class DynamoidStorageBackend < StorageBackend
        def store_event(event)
          data = message_to_json_string(event)
          DynamoEventStore.store! event, data
        end

        def store_command(command)
          data = message_to_json_string(command)
          DynamoCommandStore.store! command, data
        end

        def load_events_by_aggregate_id(aggregate_id)
          DynamoEventStore.where(aggregate_id: aggregate_id).all.map do |stored_event|
            json_string_to_message stored_event.data
          end
        end

        def load_commands_by_aggregate_id(aggregate_id)
          DynamoCommandStore.where(aggregate_id: aggregate_id).all.map do |stored_command|
            json_string_to_message stored_command.data
          end
        end
      end
    end
  rescue LoadError
    # This is intentional to no do anything if it is not loadable.
  end
end
