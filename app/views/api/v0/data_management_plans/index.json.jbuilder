# frozen_string_literal: true

json.partial! 'api/v0/standard_response', items: @payload[:items]

# rubocop:disable Metrics/BlockLength
json.items @dmps.each do |dmp|
  json.dmp do
    doi = dmp.dois.first
    next unless doi.present?

    json.schema 'https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard/tree/master/examples/JSON/JSON-schema/1.0'
    json.title dmp.title
    json.description dmp.description
    json.created dmp.created_at.to_s
    json.modified dmp.updated_at.to_s

    json.dmp_id do
      # json.uri api_v0_data_management_plan_url(doi).gsub(/%2F/, '/')
      json.partial! 'api/v0/rda_common_standard/identifiers_show', identifier: doi
    end

    json.contact do
      affiliation = dmp.primary_contact.organizations.last

      json.name dmp.primary_contact.name
      json.affiliation do
        json.name affiliation.name
        json.affiliation_id do
          json.partial! 'api/v0/rda_common_standard/identifiers_show',
                        identifier: affiliation.rors.first
        end
      end
      json.contact_id do
        json.partial! 'api/v0/rda_common_standard/identifiers_show',
                      identifier: dmp.primary_contact.orcids.first
      end
    end
    # json.authors dmp.authors
  end
end
# rubocop:enable Metrics/BlockLength
