# frozen_string_literal: true

module Aggregates
  # The event class defines the entry point that all Events in your domain should
  # subclass from. An Event describes something that happened. They are named in passed tense.
  # For instance, if the user's email has changed, then you might create an event type called
  # UserEmailChanged.
  class Event < DomainMessage
    attribute :sequence_number
    validates_presence_of :sequence_number
  end
end
