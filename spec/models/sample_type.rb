require 'rails_helper'

RSpec.describe SampleType, type: :model do

  context 'initialization' do

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

      aft1 = ft2.allowable_field_types.create sample_type_id: SampleType.find_by(name: 'Primer').id
      aft1.save

      expect(aft1.errors.empty?).to be true

      aft2 = ft2.allowable_field_types.create sample_type_id: SampleType.find_by(name: 'Primer').id
      aft2.save

      expect(aft2.errors.empty?).to be true

      st.field_types.each do |ft|
        puts ft.name
        puts ft.ftype
        ft.allowable_field_types.each do |aft|
          puts "  #{aft.inspect}"
          puts "    #{aft.sample_type.inspect}"
        end
        puts '-'
      end

      s = st.create_sample(
        name: 'my_wingbat',
        description: 'a wingbat test',
        user_id: 1,
        project: 'Auxin',
        age: 123,
        template: [] # SampleType.find_by_name("Primer").samples.first
      )

      puts s.errors.full_messages.join(',')
      expect(s.errors.empty?).to be true

      puts s.inspect
      s.field_values.each do |fv|
        puts "#{fv.name}: #{fv.val.inspect}"
      end

    end

  end

end
