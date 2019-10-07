# frozen_string_literal: true

require 'serrano'
require 'linkeddata'

# Service that communicates with the Fundref API
class FundrefService

  include RDF

  class << self

    # Searches the Fundref API for the name
    def find_by_name(name:)
      return nil unless name.present?

      json = Serrano.funders()
      process_error(action: 'find_by_name', response: json) unless json.fetch('status', 'bad request') != 'ok'

      json.fetch('message', {}).fetch('items', [])
    end

    # Retrives the metadata for the given Fundref DOI
    def find_by_uri(uri:)
      return nil unless uri.present?

      doi = uri.gsub('http://dx.doi.org/', '')
      json = Serrano.funders(ids: [doi]).first
      process_error(action: 'find_by_uri', response: json) unless json.fetch('status', 'bad request') != 'ok'

      json.fetch('message', {}).fetch('name', nil)
    rescue StandardError => e
      process_error(action: 'find_by_uri', response: json, msg: e.message)
      nil
    end

    def retrieve_full_funder_rdf
      uri = 'https://gitlab.com/crossref/open_funder_registry/blob/master/registry.rdf'

      repo = RDF::Repository.load(uri)
      repo.each_statement do |statement|
        #puts "subject: #{statement.subject}, predicate: #{statement.predicate}, object: #{statement.object}"
        p statement.to_triple
      end

    end

    private

    def headers
      {
        'User-Agent': Rails.application.class.name.split('::').first,
        'Accept': 'application/json'
      }
    end

    def process_error(action:, response:, msg: nil)
      return nil unless action.present?

      Rails.logger.error "FundrefService error during #{action}: HTTP status: #{response&.fetch('status', '')}"
      Rails.logger.error "FundrefService message: #{msg}" if msg.present?
      Rails.logger.error "FundrefService body: #{response}" if response.present?
    end

  end
end