# frozen_string_literal: true

module Aggregates
  begin
    require 'dynamoid'

    module Dynamoid
      class DynamoEventStore
        include Dynamoid::Document

        field :aggregate_id
        field :sequence_number, :integer
        field :data

        table name: :events, hash_key: :aggregate_id, range_key: :sequence_number, timestamps: true
      end

      class DynamoCommandStore
        include Dynamoid::Document

        field :aggregate_id
        field :data

        table name: :commands, hash_key: :aggregate_id, range_key: :created_at, timestamps: true
      end

      class DynamoidStorageBackend < StorageBackend
        def store_event(event)
          data = JSON.dump event.to_json
          args = { aggregate_id: event.aggregate_id, sequence_number: event.sequence_number, data: data }
          event = DynamoEventStore.new args
          event.save!
        end

        def store_command(command)
          data = JSON.dump command.to_json
          args = { aggregate_id: command.aggregate_id, data: data }
          command = DynamoCommandStore.new args
          command.save!
        end

        def load_events_by_aggregate_id(aggregate_id)
          DynamoEventStore.where(aggregate_id: aggregate_id).all.map do |stored_event|
            json = stored_event.data
            JSON.parse json, create_additions: true
          end
        end

        def load_commands_by_aggregate_id(aggregate_id)
          DynamoCommandStore.where(aggregate_id: aggregate_id).all.map do |stored_command|
            json = stored_command.data
            JSON.parse json, create_additions: true
          end
        end
      end
    end
  rescue LoadError
    # This is intentional to no do anything if it is not loadable.
  end
end
