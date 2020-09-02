# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ObjectType, type: :model do
  context 'import' do

    it 'dimensions should match import' do
      object_types = [
        {
          id: 452,
          name: 'Eppendorf 96 Deepwell Plate',
          description: 'Eppendorf 96 Deepwell Plate',
          min: 0,
          max: 100000,
          handler: 'collection',
          safety: 'No safety information',
          cleanup: 'No cleanup information',
          data: '{\"working_vol\": \"1000_uL\", \"max_vol\": \"1.2_mL\" }',
          vendor: 'No vendor information',
          created_at: '2014-11-09T18:55:06.000-08:00',
          updated_at: '2019-08-14T20:14:05.000-07:00',
          unit: 'plate',
          cost: 5.0,
          release_method: 'return',
          release_description: '',
          sample_type_id: nil,
          image: '',
          prefix: '',
          rows: 8,
          columns: 12,
          sample_type_name: nil
        }
      ]
      response = ObjectType.compare_and_upgrade(object_types)
      expect(response).not_to be_nil
      object_type = object_types.first
      plate_type = ObjectType.find_by(name: object_type[:name])
      expect(plate_type).not_to be_nil
      expect(plate_type.rows).to eq(object_type[:rows])
      expect(plate_type.columns).to eq(object_type[:columns])
    end
  end

  let!(:stripwell_type) { create(:stripwell) }
  let!(:sample_container_type) { create(:dummy_stock) }
  it 'collection_type predicate is true if object_type is collection' do
    expect(stripwell_type).to be_collection_type
    expect(sample_container_type).not_to be_collection_type
  end

  it 'sample predicate is true if object_type is sample container' do
    expect(stripwell_type).not_to be_sample
    expect(sample_container_type).to be_sample
  end

  it 'rows only works if object is collection' do
    expect(stripwell_type.rows).to eq(1)
    expect(sample_container_type.rows).to be_nil
  end

  it 'columns only works if object type is collection' do
    expect(stripwell_type.columns).to eq(12)
    expect(sample_container_type.columns).to be_nil
  end
  it 'default_dimensions raises exception if object is not collection' do
    expect { sample_container_type.default_dimensions }.to raise_error
  end

  it 'part type expectations'
end
