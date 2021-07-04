# frozen_string_literal: true

require 'dry-struct'

module Aggregates
  class DomainMessage < Dry::Struct
    attribute :aggregate_id, Types::String
    attribute :message_id, Types::String

    def to_json(*args)
      json_data = attributes.merge({ JSON.create_id => self.class.name })
      json_data.to_json(args)
    end

    def self.json_create(arguments)
      new arguments
    end
  end
end
