# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ispec, type: :model do

  context 'initialization' do

    it 'initializes from attributes' do
      is = Ispec.new name: 'whatever'
      expect(is.name).to eq('whatever')
    end

    it 'ignores unknown attributes' do
      is = Ispec.new nome: 'whatever'
    end

  end

  context 'satisfied by an item' do

    st = SampleType.find_by_name('Primer')
    s = st.samples[100]
    i = s.items.last

    it 'is satisfied by an item when it specifies a single item' do
      is = Ispec.new alternatives: [{ item: i.id }]
      expect(is.satisfied_by?(i)).to eq(true)
    end

    it 'is satisfied by an item when it specifies a list of items' do
      is = Ispec.new alternatives: [{ item: i.id }, { item: 2 }]
      expect(is.satisfied_by?(i)).to eq(true)
    end

    it 'is not satisfied by an item when it specifies list of non-matching items' do
      is = Ispec.new alternatives: [{ item: 1 }, { item: 2 }]
      expect(is.satisfied_by?(i)).to eq(false)
    end

    it 'is satisfied by an item when it specifies a container type' do
      is = Ispec.new alternatives: [{ container: i.object_type.id }]
      expect(is.satisfied_by?(i)).to eq(true)
    end

    it 'is satisfied by an item when it specifies a sample' do
      is = Ispec.new alternatives: [{ sample: s.id }]
      expect(is.satisfied_by?(i)).to eq(true)
    end

    it 'is satisfied by an item when it specifies a sample type' do
      is = Ispec.new alternatives: [{ sample_type: st.id }]
      expect(is.satisfied_by?(i)).to eq(true)
    end

  end

  context 'satisfied_by a matrix' do

    st = SampleType.find_by_name('Primer')
    s = st.samples[100]
    i = s.items.last

    it 'is satisfied by a matrix of items' do
      is = Ispec.new is_matrix: true, rows: 1, columns: 1, alternatives: [{ sample: s.id }]
      expect(is.satisfied_by?([[i]])).to eq(true)
    end

  end

  context 'satisfied by a part of a collection' do

    col = Collection.new quantity: 1, inuse: 0, object_type_id: ObjectType.find_by_name('Stripwell').id
    col.matrix = [[SampleType.find_by_name('Primer').samples.first.id]]
    col.save
    part = Part.new col, 0, 0
    s = part.sample

    it 'is satisfied by a part' do
      is = Ispec.new is_part: true, alternatives: [{}]
      expect(is.satisfied_by?(part)).to eq(true)
    end

    it 'is satisfied by a part when an object type is specified' do
      is = Ispec.new is_part: true, alternatives: [{ container: col.object_type.id }]
      expect(is.satisfied_by?(part)).to eq(true)
    end

    it 'is satisfied by a part when an object type and a sample are specified' do
      is = Ispec.new is_part: true, alternatives: [{ container: col.object_type.id, sample: s.id }]
      expect(is.satisfied_by?(part)).to eq(true)
    end

    it 'is satisfied by a part when a specific collection is specified' do
      is = Ispec.new is_part: true, alternatives: [{ item: col.id }]
      expect(is.satisfied_by?(part)).to eq(true)
    end

    it 'is satisfied by a part when a specific collection and row and column are specified' do
      is = Ispec.new is_part: true, alternatives: [{ item: col.id, row: 0, column: 0 }]
      expect(is.satisfied_by?(part)).to eq(true)
    end

    it 'is not satisfied by a part when a specific collection, row and column are incorrectly specified' do
      is = Ispec.new is_part: true, alternatives: [{ item: col.id, row: 0, column: 1 }]
      expect(is.satisfied_by?(part)).to eq(false)
    end

  end

end
