# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecurityPrivacyStatement, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
  end

  it 'factory can produce a valid model' do
    model = create(:security_privacy_statement)
    expect(model.valid?).to eql(true)
  end
end
