# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FieldValue, type: :model do
  let!(:an_object_type) { create(:object_type, name: 'gel_type') }
  let!(:fragment_type) { create(:sample_type_with_samples, name: 'Fragment') }
  let!(:op_type) { create(:operation_type, name: 'Run Gel') }
  let!(:stripwell_type) { create(:stripwell) }

  # Tests new_collection
  def example_collection(name = 'Stripwell')
    c = Collection.new_collection(name)
    c.save
    raise "Got save errors: #{c.errors.full_messages}" if c.errors.any?

    c
  end

  def add_pins(op_type)
    op_type.add_input('Fragment', 'Fragment', 'Stripwell')
    op_type.add_output('Fragment', 'Fragment', 'gel_type')
  end

  context 'collections' do

    it 'properly finds associated parts' do

      stripwell = example_collection
      gel = example_collection 'gel_type'

      s = SampleType.find_by_name('Fragment').samples.sample
      expect(s.id).to_not be_nil
      stripwell.set 0, 0, s
      expect(stripwell.part(0, 0)).to_not be_nil
      gel.set 1, 1, s

      # op = OperationType.find_by_name("Run Gel").operations.create
      add_pins(op_type)
      op = op_type.operations.create

      op.set_input('Fragment', s)
      expect(op.input('Fragment')).to_not be_nil
      op.input('Fragment').set(item: stripwell, row: 0, column: 0)
      expect(op.input('Fragment').collection_part(0, 0)).to_not be_nil
      expect(op.input('Fragment').collection_part(0, 0).sample.id).to eq(s.id)

      op.set_output('Fragment', s)
      op.output('Fragment').set(item: gel, row: 1, column: 1)

      expect(op.output('Fragment').collection_part(1, 1).sample.id).to eq(s.id)
      expect(op.input('Fragment').collection_part(0, 1)).to eq(nil)

    end

  end

end
