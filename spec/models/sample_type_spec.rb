

require 'rails_helper'

RSpec.describe SampleType, type: :model do
  let!(:fragment_type) { create(:sample_type_with_samples, name: "Primer") }

  context 'initialization' do

    it "cannot have two sample types of the same name" do

      name = "Wingbat"

      st = SampleType.new name: name, description: 'A test sample type'
      st.save

      expect(st.errors.empty?).to be true        

      st = SampleType.new name: name, description: 'A test sample type'
      st.save   

      expect(st.errors.empty?).to be false         

    end

    it 'can have field types added to it' do

      st = SampleType.new name: 'Wingbat', description: 'A test sample type'
      st.save

      expect(st.errors.empty?).to be true

      ft1 = st.field_types.create name: 'age', ftype: 'number', required: true
      ft1.save

      expect(ft1.errors.empty?).to be true

      ft2 = st.field_types.create name: 'template', ftype: 'sample', array: true, required: true
      ft2.save

      expect(ft2.errors.empty?).to be true

      aft1 = ft2.allowable_field_types.create sample_type_id: SampleType.find_by_name('Primer').id
      aft1.save

      expect(aft1.errors.empty?).to be true

      aft2 = ft2.allowable_field_types.create sample_type_id: SampleType.find_by_name('Primer').id
      aft2.save

    end

  end

end
