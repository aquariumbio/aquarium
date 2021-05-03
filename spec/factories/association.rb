# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :data_association do
    transient do
      owner { create(:plan) }
      parent_id { owner.id }
      parent_class { owner.class }
    end

    key { 'key' }
    value { 'value' }
    initialize_with { DataAssociation.create_from(parent_id: parent_id, parent_class: parent_class, key: key, value: value)}

  end

end
