# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do

  let!(:stripwell_type) { create(:stripwell) }
  let!(:test_sample) { create(:sample) }

  # TODO: change to properly use factories

  # Tests new_collection
  def example_collection(name = 'Stripwell')
    c = Collection.new_collection(name)
    c.save
    raise "Got save errors: #{c.errors.full_messages}" if c.errors.any?

    c
  end

  def make_96_well_pcr_collection
    ot = ObjectType.find_by name: '96 qPCR collection'
    return ot if ot

    ObjectType.new(
      name: '96 qPCR collection',
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
      rows: 8,
      columns: 12
    ).save
  end

  context 'data' do

    it "doesn't screw up sample associations after setting data" do

      plate = example_collection 'Stripwell'

      id = test_sample.id

      sample_matrix = JSON.parse("[[#{id},#{id},#{id},#{id},#{id},null,null,null,null,null,null,null]]")

      data_matrix = (0...1).collect { |i| (0..11).collect { |j| 12 * i + j } }

      plate.associate_matrix(sample_matrix)

      expect(plate.part_association_list.length).to equal(5)

      plate.set_data_matrix('x', data_matrix)
      expect(plate.part_association_list.length).to equal(12)

      pa_matrix = (0...1).collect { |i| (0..11).collect { |j| plate.part_association i, j } }
      part_id_matrix = pa_matrix.collect do |row|
        row.collect { |pa| pa ? pa.part_id : nil }
      end

      expect(part_id_matrix.flatten.length).to equal(12)
      expect(plate.num_samples).to equal(5)
    end

    it 'gets data associations whether its an item or a collection' do
      c = example_collection
      c.associate :a, 1
      i = Item.find(c.id)
      i.associate :b, 2
      raise 'not all keys found' unless Collection.find(c.id).associations.keys.length == 2
      raise 'not all keys found' unless Item.find(c.id).associations.keys.length == 2
    end

    it 'gets the right data association matrix' do

      c = example_collection
      c.set 0, 0, Sample.last
      c.set 0, 3, Sample.last
      c.part(0, 0).associate 'x', 1.0
      c.part(0, 3).associate 'y', 'hello world'

      m = c.data_matrix 'x'
      raise 'did not find association x' unless m[0][0].key == 'x' && m[0][0].value == 1.0

      m = c.data_matrix 'y'
      raise 'did not find association y' unless m[0][3].key == 'y' && m[0][3].value == 'hello world'

      m = c.data_matrix 'z'
      raise 'did not gracefully deal with lack of data association' unless m[0][0].nil?
      raise 'did not gracefully deal with lack of part' unless m[0][1].nil?

    end

    it 'can set data associations of parts' do

      c = example_collection
      c.set_data_matrix 'x', [[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2]]
      c.set_data_matrix 'y', [%w[A B C D E F G H I J K L]]

      raise 'did not set matrix' unless c.get_part_data('x', 0, 11) == 1.2 && c.get_part_data('y', 0, 0) == 'A'

      c.set_part_data 'y', 0, 5, 'f'
      raise 'did not set specific element' unless c.get_part_data('y', 0, 5) == 'f'

      c.drop_data_matrix 'x'
      c.drop_data_matrix 'y'

      make_96_well_pcr_collection
      d = example_collection '96 qPCR collection'
      d.set_data_matrix 'z', [[100, 200], [400, 500]], offset: [4, 3]

      raise 'did not set data matrix with offset' unless d.data_matrix('z')[5][4].value == 500

    end

    it 'makes an empty data matrix' do

      make_96_well_pcr_collection
      d = example_collection '96 qPCR collection'
      d.new_data_matrix 'x'
      m = d.data_matrix 'x'
      nz = m.collect { |row| row.collect { |da| da.value } }.flatten.reject { |x| x == 0.0 }
      raise 'did not make empty data matrix' unless nz.empty?

      d.drop_data_matrix 'x'
      m = d.data_matrix 'x'
      nn = m.collect { |row| row.collect { |da| da } }.flatten.compact
      raise 'did not drop data matrix' unless nn.empty?

    end

  end

end
