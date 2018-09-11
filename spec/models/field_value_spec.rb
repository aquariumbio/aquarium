require 'rails_helper'

RSpec.describe FieldValue, type: :model do

  # Tests new_collection
  def example_collection name="Stripwell"
    c = Collection.new_collection(name)
    c.save
    raise "Got save errors: #{c.errors.full_messages}" if c.errors.any?
    c
  end

  context 'collections' do

    it "properly finds associated parts" do

      stripwell = example_collection
      gel = example_collection "50 mL 0.8 Percent Agarose Gel in Gel Box"
      s = SampleType.find_by_name("Fragment").samples.sample
      stripwell.set 0, 0, s
      gel.set 1, 1, s

      op = OperationType.find_by_name("Run Gel").operations.create

      op.set_input("Fragment", s)
      op.input("Fragment").set(item: stripwell, row: 0, column: 0)

      op.set_output("Fragment", s)
      op.output("Fragment").set(item: gel, row: 1, column: 1)

      unless op.input("Fragment").collection_part(0,0).sample.id == s.id &&
             op.output("Fragment").collection_part(1,1).sample.id == s.id &&
             op.input("Fragment").collection_part(0,1) == nil
        raise "Could not find parts" 
      end

    end

  end

end