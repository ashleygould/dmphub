# frozen_string_literal: true

FactoryBot.define do
  factory :data_management_plan do
    title                       { Faker::Movies::StarWars.wookiee_sentence }
    description                 { Faker::Lorem.paragraph }
    ethical_issues              { [nil, true, false].sample }
    ethical_issues_description  { Faker::Lorem.paragraph }
    ethical_issues_report       { Faker::Internet.url }
    language                    { Api::V0::ConversionService::LANGUAGES.sample }

    before :create do |data_management_plan|
      data_management_plan.provenance = build(:provenance) unless data_management_plan.provenance.present?
    end

    trait :complete do
      transient do
        contributors_count { 1 }
        datasets_count     { 1 }
        costs_count        { 1 }
        identifiers_count  { 1 }
      end

      after :create do |data_management_plan, evaluator|
        # Ensure there is a primary contact!
        data_management_plan.primary_contact = create(:contributor, :complete)

        # Add contributors
        evaluator.contributors_count.times do
          per = create(:contributor, :complete)
          j = create(:contributors_data_management_plan, contributor: per, data_management_plan: data_management_plan,
                                                         role: ContributorsDataManagementPlan.roles.keys.sample)
          data_management_plan.contributors_data_management_plans << j
        end
        evaluator.costs_count.times do
          data_management_plan.costs << create(:cost)
        end
        evaluator.datasets_count.times do
          data_management_plan.datasets << create(:dataset, :complete)
        end
        evaluator.identifiers_count.times do
          data_management_plan.identifiers << create(:identifier, category: 'doi',
                                                                  identifiable: data_management_plan,
                                                                  descriptor: Identifier.descriptors.keys.sample)
        end
      end
    end
  end
end
