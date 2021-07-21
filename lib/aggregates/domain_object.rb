# frozen_string_literal: true

require 'active_model'

module Aggregates
  # Defines an object that is an element of the domain.
  class DomainObject
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Attributes

    validate :validate_nested_fields

    def to_json(*args)
      json_data = attributes.merge({ JSON.create_id => self.class.name })
      json_data.to_json(*args)
    end

    def self.json_create(arguments)
      new(**arguments)
    end

    protected

    def add_nested_errors_for(attribute, other_validator)
      nested_errors = other_validator.errors
      errors.messages[attribute] = nested_errors.messages
      errors.details[attribute]  = nested_errors.details
    end

    def validate_nested_fields
      attributes.each do |key, value|
        add_nested_errors_for(key.to_sym, value) if value.is_a?(DomainObject) && !value.valid?
      end
    end
  end
end
