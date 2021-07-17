# frozen_string_literal: true

module Aggregates
  # The DomainMessage is not a class that should generally be interacted with unless
  # extending Aggregates itself. It provides some core functionality that message types
  # (Event and Command) both require.
  class DomainMessage < DomainObject
    def initialize(attributes = {})
      super
      @created_at = Time.now
      @message_id = Aggregates.new_message_id
    end

    field :aggregate_id, :message_id, :created_at
    validates_presence_of :aggregate_id, :message_id, :created_at
  end
end
