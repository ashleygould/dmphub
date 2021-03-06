# frozen_string_literal: true

# A data management plan
class DataManagementPlan < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Associations
  belongs_to :project, optional: true

  has_many :contributors_data_management_plans, dependent: :destroy
  has_many :contributors, through: :contributors_data_management_plans
  has_many :costs, dependent: :destroy
  has_many :datasets, dependent: :destroy
  has_many :history, class_name: 'ApiClientHistory', dependent: :destroy

  accepts_nested_attributes_for :costs, :datasets, :project,
                                :contributors_data_management_plans

  # Validations
  validates :title, presence: true

  # Callbacks
  before_validation :ensure_dataset

  # Scopes
  scope :by_client, lambda { |client_id:|
    where(api_client_id: client_id)
  }

  scope :search, lambda { |term:|
    clause = <<-SQL
      data_management_plans.title LIKE ?
        OR projects.title LIKE ?
        OR data_management_plans.description LIKE ?
        OR identifiers.value = ?
        OR contributors.name LIKE ?
        OR contributors.email = ?
    SQL
    left_outer_joins(:project, :identifiers, contributors_data_management_plans: :contributor)
      .where(clause, "%#{term}%", "%#{term}%", "%#{term}%", term, "%#{term}%", term)
      .distinct
      .order(updated_at: :desc)
  }

  # Class Methods
  class << self
    def find_by_organization(affiliation_id:)
      return all unless affiliation_id.present?

      joins(:identifiers, contributors_data_management_plans: { contributor: :contributors_affiliations })
        .joins('INNER JOIN affiliations p_org ON `contributors_affiliations`.`affiliation_id` = p_org.id')
        .includes(:identifiers, contributors_data_management_plans: { contributor: :contributors_affiliations })
        .where('p_org.id = ?', affiliation_id)
    end

    def find_by_funder(affiliation_id:)
      return all unless affiliation_id.present?

      joins(:identifiers, project: :awards)
        .joins('INNER JOIN affiliations a_org ON `fundings`.`affiliation_id` = a_org.id')
        .includes(:identifiers, project: :fundings)
        .where('a_org.id = ?', affiliation_id)
    end
  end

  # Instance Methods

  def primary_contact
    contributors_data_management_plans.select { |cdmp| cdmp.role == 'primary_contact' }
                                      .first&.contributor
  end

  # rubocop:disable Style/GuardClause
  def primary_contact=(contributor)
    if contributor.is_a?(Contributor)
      # See if there is already a Primary Contact defined.
      current = contributors_data_management_plans.where(role: 'primary_contact').first
      # Delete the old one
      current.destroy if current.present? && current.contributor != contributor
      unless current.present?
        # Add the new one
        contributors_data_management_plans << ContributorsDataManagementPlan.new(
          contributor: contributor, role: 'primary_contact', provenance: contributor.provenance
        )
      end
    end
  end
  # rubocop:enable Style/GuardClause

  def mint_doi(provenance:)
    # retrieve the Datacite Provenance or initialize it
    ids = ExternalApis::EzidService.mint_doi(
      data_management_plan: self,
      provenance: provenance
    )
    identifiers << ids.flatten.compact
    dois.present? || arks.present?
  end

  private

  # Create a default stub dataset unless one exists
  def ensure_dataset
    datasets << Dataset.new(title: title, provenance: provenance) unless datasets.any?
  end
end
