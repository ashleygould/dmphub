# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiClientPermission, type: :model do
  context 'validations' do
    subject { create(:api_client_permission, api_client: create(:api_client)) }

    it { is_expected.to define_enum_for(:permission).with_values(ApiClientPermission.permissions.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:api_client) }
  end

  context 'instance methods' do
    before(:each) do
      @award1 = create(:funding, status: 'planned', affiliation: create(:affiliation))
      @award2 = create(:funding, status: 'applied', affiliation: create(:affiliation))
      rules = 'SELECT * FROM fundings where status = 0;'
      @model = build(:api_client_permission, rules: rules, permission: 'funding_assertion')
    end

    describe '#authorized_entities' do
      it 'returns [] if no :rules is defined' do
        @model.rules = nil
        expect(@model.authorized_entities).to eql([])
      end
      it 'returns true if the :secret matches' do
        results = @model.authorized_entities
        expect(results.length).to eql(1)
        expect(results.include?(@award1.id)).to eql(true)
        expect(results.include?(@award2.id)).to eql(false)
      end
    end

    describe '#authorized?(obj:)' do
      it 'returns false if no :rules is defined' do
        @model.rules = nil
        expect(@model.authorized?(object: @award1)).to eql(false)
      end
      it 'returns false if no :object is specified' do
        expect(@model.authorized?(object: nil)).to eql(false)
      end
      it 'returns false if no :object is the wrong type for the permission' do
        expect(@model.authorized?(object: Project.new)).to eql(false)
      end
      it 'returns false if the :rules check does not pass' do
        expect(@model.authorized?(object: @award2)).to eql(false)
      end
      it 'returns true if the :rules check passes' do
        expect(@model.authorized?(object: @award1)).to eql(true)
      end
    end
  end
end
