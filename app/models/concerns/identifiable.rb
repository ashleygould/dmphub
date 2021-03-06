# frozen_string_literal: true

# Hook to add association to Identifier
module Identifiable
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    has_many :identifiers, as: :identifiable, dependent: :destroy

    validates_associated :identifiers

    accepts_nested_attributes_for :identifiers

    Identifier.categories.each_key do |category|
      # Dynamically create methods accessor methods for each Identifier category
      # a method to get specific identifier types (e.g. `orcids`)
      define_method(category.downcase.pluralize) do
        identifiers.select { |i| i.category == category }
      end
    end

    class << self
      # Dynamically create methods accessor methods for each Identifier category
      # a scope to find by each Identifier category (e.g. `find_orcid(:value)`)
      Identifier.categories.each_key do |category|
        define_method("find_by_#{category.downcase}") do |value|
          ids = Identifier.where(
            category: category,
            identifiable_type: name,
            value: value
          ).pluck(:identifiable_id)
          where(id: ids)
        end
      end

      def find_by_identifiers(provenance:, json_array:)
        return nil unless json_array.is_a?(Array) && provenance.present?

        obj = nil
        # Loop through the identifiers and if we find a match then return the
        # asscociated model
        json_array.each do |json|
          json = json.with_indifferent_access
          next unless json['value'].present? && json['category'].present?

          obj = find_association(provenance: provenance, json: json)
          break if obj.present?
        end
        obj
      end

      private

      def find_association(provenance:, json:)
        json = json.with_indifferent_access
        identifier = Identifier.where(
          provenance: provenance,
          value: json['value'],
          category: json['category'],
          identifiable_type: name
        ).first
        where(id: identifier.identifiable_id).first if identifier.present?
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
