# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:dummy_sample_type) { create(:sample_type, name: 'DummySampleType') }
  let!(:dummy_sample) { create(:sample, name: 'DummySample', sample_type: dummy_sample_type) }
  let!(:regular_object_type){ create(:dummy_stock) }
  let(:regular_item){ create(:item, sample_id: dummy_sample.id, object_type_id: regular_object_type.id)}

  let!(:collection_object_type){ create(:stripwell) }

  it 'item is a collection if object type is a collection' do
    expect(regular_item).not_to be_collection
  end

  it 'items_for returns a collection if object_type is collection' do
    c = Collection.new_collection("stripwell")
    expect(c).to be_collection
  end
end
