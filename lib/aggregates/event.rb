# frozen_string_literal: true

module Aggregates
  class Event < DomainMessage
    attribute :sequence_number, Types::Integer
  end
end
