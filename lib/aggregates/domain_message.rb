# frozen_string_literal: true

module Aggregates
  # The DomainMessage is not a class that should generally be interacted with unless
  # extending Aggregates itself. It provides some core functionality that message types
  # (Event and Command) both require.
  class DomainMessage < DomainObject
    def initialize(attributes = {})
      super(attributes.merge({ message_id: Aggregates.new_message_id, created_at: Time.now }))
    end

    attribute :aggregate_id
    attribute :message_id
    attribute :created_at
    validates_presence_of :aggregate_id, :message_id, :created_at
  end
end
