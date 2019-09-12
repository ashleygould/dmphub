# frozen_string_literal: true

# Represents an identifier (e.g. ORCID, email, DOI, etc.)
class Identifier < ApplicationRecord
  enum category: %i[ark doi grid orcid ror url]

  # Associations
  belongs_to :identifiable, polymorphic: true

  # Validations
  validates :category, :value, :provenance, presence: true
  validates :value, uniqueness: { scope: %i[category provenance], case_sensitive: false }

  # Callbacks
  before_validation :ensure_provenance

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present?

      json = json.with_indifferent_access
      return nil unless json['value'].present?

      new(category: json.fetch('category', 'url'), provenance: provenance, value: json.fetch('value', ''))
    end

  end

  private

  def ensure_provenance
    provenance = Rails.application.class.name.underscore unless provenance.present?
  end
end