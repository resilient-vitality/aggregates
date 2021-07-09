# frozen_string_literal: true

require 'dry-struct'

module Aggregates
  # The DomainMessage is not a class that should generally be interacted with unless
  # extending Aggregates itself. It provides some core functionality that message types
  # (Event and Command) both require.
  class DomainMessage < Dry::Struct
    attribute :aggregate_id, Types::String
    attribute :message_id, Types::String.default { Aggregates.new_message_id }
    attribute :created_at, Types::Strict::DateTime.default { Time.now }

    def to_json(*args)
      json_data = attributes.merge({ JSON.create_id => self.class.name })
      json_data.to_json(args)
    end

    def self.json_create(arguments)
      new arguments
    end
  end
end
