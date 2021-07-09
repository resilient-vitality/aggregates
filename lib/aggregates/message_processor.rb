# frozen_string_literal: true

module Aggregates
  # MessageProcessor is a set of helper methods for routing messages
  # to handlers defined at the class level for DomainMessages.
  module MessageProcessor
    # Provides a single mapping of Message Classes to a list of handler
    # blocks that should be executed when that type of message is received.
    module ClassMethods
      def on(*message_classes, &block)
        message_classes.each do |message_class|
          handlers = message_mapping[message_class] ||= []
          handlers.append block
        end
      end

      def message_mapping
        @message_mapping ||= {}
      end

      def handles_message?(message)
        message_mapping.key?(message.class)
      end
    end

    def self.included(host_class)
      host_class.extend(ClassMethods)
    end

    def handle_message(message)
      search_class = message.class
      results = []

      while search_class != DomainMessage
        handlers = self.class.message_mapping[search_class]
        handlers&.each do |handler|
          results << instance_exec(message, &handler)
        end
        search_class = search_class.superclass
      end

      results
    end
  end
end
