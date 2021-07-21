# frozen_string_literal: true

require 'securerandom'

require_relative './aggregates/domain_object'
require_relative './aggregates/domain_message'
require_relative './aggregates/message_processor'

require_relative './aggregates/aggregate_root'
require_relative './aggregates/auditor'
require_relative './aggregates/command'
require_relative './aggregates/command_processor'
require_relative './aggregates/command_filter'
require_relative './aggregates/command_validation_error'
require_relative './aggregates/domain'
require_relative './aggregates/domain_executor'
require_relative './aggregates/event'
require_relative './aggregates/event_processor'
require_relative './aggregates/event_stream'
require_relative './aggregates/value_object'

require_relative './aggregates/storage_backend'
require_relative './aggregates/in_memory_storage_backend'

# A helpful library for building CQRS and Event Sourced Applications.
module Aggregates
  def self.new_aggregate_id
    new_uuid
  end

  def self.new_message_id
    new_uuid
  end

  def self.create_domain(&block)
    domain = Domain.new
    domain.instance_exec(&block)
    domain
  end

  def self.new_uuid
    SecureRandom.uuid.to_s
  end
end
