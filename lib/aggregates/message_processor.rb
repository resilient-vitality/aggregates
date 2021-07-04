# frozen_string_literal: true

module Aggregates
  module MessageProcessor
    module ClassMethods
      def on(*message_classes, &block)
        message_classes.each do |message_class|
          message_mapping[message_class] ||= []
          message_mapping[message_class] << block
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

      while search_class != Message
        handlers = self.class.message_mapping[search_class]
        handlers&.each do |handler|
          instance_exec(message, &handler)
        end
        search_class = search_class.superclass
      end
    end
  end
end
