# frozen_string_literal: true

module Aggregates
  class EventProcessor
    include MessageProcessor

    def process_event(event)
      handle_message event
    end
  end
end
