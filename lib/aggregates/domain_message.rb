# frozen_string_literal: true

require 'dry-struct'

module Aggregates
  class DomainMessage < Dry::Struct
    attribute :aggregate_id, Types::String
    attribute :message_id, Types::String
  end
end
