# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Host, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:distribution) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:host)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'hosts.json')
    end

    it 'invalid JSON does not create a valid Host instance' do
      validate_invalid_json_to_model(clazz: Host, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Host instance' do
      obj = validate_minimal_json_to_model(clazz: Host, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
    end

    it 'complete JSON creates a valid Host instance' do
      obj = validate_complete_json_to_model(clazz: Host, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(ConversionService.boolean_to_yes_no_unknown(obj.supports_versioning)).to eql(@json['supports_versioning'])
      expect(obj.backup_type).to eql(@json['backup_type'])
      expect(obj.backup_frequency).to eql(@json['backup_frequency'])
      expect(obj.storage_type).to eql(@json['storage_type'])
      expect(obj.availability).to eql(@json['availability'])
      expect(obj.geo_location).to eql(@json['geo_location'])
      expect(obj.identifiers.first.value).to eql(@json['host_ids'].first['value'])
    end
  end
end