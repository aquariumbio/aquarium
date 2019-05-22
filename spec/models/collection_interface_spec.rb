# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do

  let!(:stripwell_type) { create(:stripwell) }
  let!(:test_sample) { create(:sample) }
  let!(:sample_list) { create_list(:sample, 24) }

  # Tests new_collection
  def example_collection(name = 'Stripwell')
    c = Collection.new_collection(name)
    c.save
    raise "Got save errors: #{c.errors.full_messages}" if c.errors.any?

    c
  end

  def make_24_well_tube_rack
    ot = ObjectType.find_by_name '24-Slot Tube Rack'
    return ot if ot

    ObjectType.new(
      name: '24-Slot Tube Rack',
      description: '96 qPCR collection',
      min: 0,
      max: 1,
      handler: 'collection',
      safety: 'No safety information',
      cleanup: 'No cleanup information',
      data: 'No data', vendor: 'No vendor information',
      unit: 'part',
      cost: 0.01,
      release_method: 'return',
      release_description: '',
      image: '',
      prefix: '',
      rows: 4,
      columns: 6
    ).save
  end

  context 'associations' do

    it 'sets up the right associations' do
      samples = Sample.all.sample(9)
      collections = Collection.spread(samples, 'Stripwell')
      c = collections[0]
      x = c.part_associations.map(&:id).sort
      y = PartAssociation.where(collection_id: c.id).map(&:id).sort
      raise 'part association not working for collection' unless x == y
    end

  end

  context 'collisions' do

    it 'should not put two parts at the same location in the same collection' do

      c = example_collection
      d = example_collection

      pa = PartAssociation.new collection_id: c.id, part_id: 1, row: 1, column: 2
      pa.save
      pa = PartAssociation.new collection_id: c.id, part_id: 2, row: 1, column: 2

      begin
        pa.save
        raise 'Collision allowed'
      rescue StandardError
      end

      pa = PartAssociation.new collection_id: c.id, part_id: 1, row: 2, column: 2
      pa.save
      pa = PartAssociation.new collection_id: d.id, part_id: 2, row: 2, column: 3

      begin
        pa.save
        raise 'Collision allowed'
      rescue StandardError
        raise 'Non collision detected' unless pa.errors.empty?
      end

    end

  end

  context 'construction' do

    # tests new_collection
    #         => apportion
    #       matrix
    it 'can make new collections' do
      c = example_collection
      raise 'Wrong size' unless c.matrix.length == 1 && c.matrix[0].length == 12
    end

    # tests new_collection
    #       matrix
    #       set
    it 'can set parts' do
      c = example_collection
      c.set 0, 5, test_sample
      raise 'Did not set part' unless c.matrix[0][5] == test_sample.id
      raise "string view #{c.non_empty_string} incorrect" unless c.non_empty_string == '1 - 6'
    end

  end

  context 'finding' do

    # tests containing
    #       position, position_as_hash
    #         => find
    #           => to_sample_id
    it 'finds collections containing a specific sample' do
      c = example_collection
      s = test_sample
      c.set 0, 5, test_sample
      Collection.containing(s).each do |item|
        collection = item.becomes Collection # TODO: Make it so that you don't have to do this
        raise 'Sample should be in collection' unless collection.position(s.id)
        raise 'Sample should be in collection' unless collection.position_as_hash(s.id)
      end
    end

    # tests parts
    #         => position_as_hash
    #         => find
    #           => to_sample_id
    it 'finds parts and their containing collections with a specific sample' do
      c = example_collection
      s = test_sample
      c.set 0, 5, s
      Collection.parts(s).each do |part|
        collection = part[:collection].becomes Collection # TODO: Make it so that you don't have to do this
        pos = collection.position_as_hash(s.id)
        raise 'Sample should be in collection in specified slot' unless pos[:row] == part[:row] && pos[:column] == part[:column]
      end
    end

  end

  context 'setting and getting' do

    # tests new_collection
    #       set
    #       get_non_empty
    #       get_empty
    #       num_samples
    #       capacity
    #         dimensions
    #       include?
    it 'can set slots to samples' do
      c = example_collection
      c.set 0, 5, test_sample
      c.set 0, 8, Sample.first
      raise 'Slots not adding up' unless c.get_empty.length + c.get_non_empty.length == c.capacity
      raise 'Non-empty not adding up' unless c.get_non_empty.length == c.num_samples
      raise 'include? not working' unless c.include?(test_sample) && c.include?(test_sample.id)

      expect(c.select { |x| x == test_sample.id }.length).to eq(2)
    end

    # test set_matrix
    #        => associate
    #      matrix
    it 'sets a matrix of samples' do
      c = example_collection
      samples = [Sample.all.sample(12).collect { |s| s }]
      c.set_matrix samples
      m = c.matrix
      (0..11).each do |i|
        expect(m[0][i]).to eq(samples[0][i].id)
      end
    end

    # test matrix=
    #      matrix
    it 'sets a matrix of sample ids' do
      c = example_collection
      samples = [Sample.all.sample(12).collect { |s| s.id }]
      c.matrix = samples
      m = c.matrix
      (0..11).each do |i|
        expect(m[0][i]).to eq(samples[0][i])
      end
    end

    # tests spread
    #         => add_samples
    #       matrix
    it 'can spread a bunch of samples across multiple collections' do
      samples = Sample.all.sample(17)
      collections = Collection.spread(samples, 'Stripwell')
      sids1 = samples.map(&:id)
      sids2 = collections.map(&:matrix).flatten.reject { |sid| sid <= 0 }
      raise 'Example sample ids not found' unless sids1 == sids2

      expect(collections[0]).to be_full
      expect(collections[1]).not_to be_full
    end

    # test set_matrix
    #        => associate
    #      matrix
    it 'can add and subtract samples' do
      c = example_collection
      c.set 0, 5, test_sample
      s = test_sample
      c.add_one(s)
      c.add_one(s)
      c.subtract_one
      raise 'add_one and subtract_one not adding up' unless c.get_non_empty.length == 2
    end

    # test next
    it 'goes to the next samples' do

      make_24_well_tube_rack
      c = example_collection '24-Slot Tube Rack'
      s = test_sample
      samples = (0...4).collect { |i| Array.new(6, s.id) }
      c.matrix = samples
      p = [0, 0]
      (0...4).each do |i|
        (0...6).each do |j|
          raise "Next didn't align with #{p} != #{[i, j]}" unless p == [i, j]

          p = c.next(p[0], p[1])
        end
      end
      c.set 1, 1, -1
      raise 'skip_non_empty option not working' unless c.next(0, 0, skip_non_empty: true) == [1, 1]
      raise "edge condition didn't work" unless c.next(3, 5) == [nil, nil]
    end

  end

end
