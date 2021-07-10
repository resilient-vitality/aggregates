# frozen_string_literal: true

require 'active_model'

module Aggregates
  # The DomainMessage is not a class that should generally be interacted with unless
  # extending Aggregates itself. It provides some core functionality that message types
  # (Event and Command) both require.
  class DomainMessage
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations

    def initialize(attributes = {})
      @created_at = Time.now
      @message_id = Aggregates.new_message_id
      assign_attributes(attributes) if attributes
    end

    def attributes
      as_json
    end

    def to_json(*args)
      json_data = attributes.merge({ JSON.create_id => self.class.name })
      json_data.to_json(*args)
    end

    def self.json_create(arguments)
      new arguments
    end

    attr_accessor :aggregate_id, :message_id, :created_at

    validates_presence_of :aggregate_id, :message_id, :created_at
  end
end
