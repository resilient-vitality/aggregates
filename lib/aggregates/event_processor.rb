# frozen_string_literal: true

module Aggregates
  # EventProcessors respond to events that have occurred from Aggregates after.
  # EventProcessors take on different roles depending on the application. The biggest
  # role to to project aggregates as they are created and updated into a readable form
  # for your application.
  class EventProcessor
    include MessageProcessor
    alias process_event handle_message
  end
end
