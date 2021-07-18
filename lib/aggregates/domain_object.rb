# frozen_string_literal: true

require 'active_model'

module Aggregates
  class DomainObject
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations

    validate :validate_nested_fields

    def initialize(attributes = {})
      assign_attributes(attributes) if attributes
    end

    def attributes
      as_json
    end

    def to_json(*args)
      json_data = attributes.merge({ JSON.create_id => self.class.name })
      json_data.to_json(*args)
    end

    def self.json_create(arguments)
      new arguments
    end

    def self.field(*fields)
      attr_accessor(*fields)
    end

    protected

    def add_nested_errors_for(attribute, other_validator)
      errors.messages[attribute] = other_validator.errors.messages
      errors.details[attribute]  = other_validator.errors.details
    end

    def validate_nested_fields
      attributes.each do |key, value|
        add_nested_errors_for(key.to_sym, value) if value.is_a?(DomainObject) && !value.valid?
      end
    end
  end
end
