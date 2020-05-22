# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contributor, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it 'validates uniqueness of email' do
      subject = create(:contributor)
      expect(subject).to validate_uniqueness_of(:email).case_insensitive
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:authorizations) }
    it { is_expected.to have_many(:data_management_plans) }
    it { is_expected.to have_many(:projects) }
    it { is_expected.to belong_to(:affiliation) }
  end

  it 'factory can produce a valid model' do
    model = create(:contributor)
    expect(model.valid?).to eql(true)
  end

  describe 'errors' do
    before :each do
      @model = build(:contributor)
    end
    it 'includes affiliation errors' do
      @model.affiliation = build(:affiliation, name: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Name can\'t be blank')).to eql(true)
    end
    it 'includes identifier errors' do
      @model.identifiers << build(:identifier, category: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Category can\'t be blank')).to eql(true)
    end
  end

  describe 'cascading deletes' do
    it 'does not delete associated data_management_plans' do
      model = create(:contributor, :complete)
      dmp = create(:data_management_plan, project: create(:project), contributors: [model])
      model.destroy
      expect(DataManagementPlan.last).to eql(dmp)
    end
    it 'does not delete associated affiliation' do
      org = create(:affiliation)
      model = create(:contributor, affiliation: org)
      model.destroy
      expect(Affiliation.last).to eql(org)
    end
    it 'deletes associated identifiers' do
      model = create(:contributor, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
    it 'deletes associated authorizations' do
      model = create(:contributor)
      create(:api_client_authorization, authorizable: model, api_client: create(:api_client))
      model.reload
      authorization = model.authorizations.first
      model.destroy
      expect(ApiClientAuthorization.where(id: authorization.id).empty?).to eql(true)
    end
  end
end