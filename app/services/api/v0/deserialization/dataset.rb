# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert a JSON representiion of a Dataset into a Dataset model
      class Dataset
        class << self
          # Convert incoming JSON into a Dataset
          #    {
          #      'title': 'Cerebral cortex imaging series',
          #      'personal_data': 'unknown',
          #      'sensitive_data': 'unknown',
          #      'dataset_id': {
          #        'type': 'doi',
          #        'identifier': 'https://doix.org/10.1234.123abc/y3'
          #      }
          #    }
          def deserialize!(json: {})
            return nil unless json.present? && json[:title].present?

            # TODO: Implement once we have determined the Dataset model
            nil
          end
        end
      end
    end
  end
end
