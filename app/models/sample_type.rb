class SampleType < ActiveRecord::Base

  include FieldTyper

  after_destroy :destroy_fields

  attr_accessible :description, :name

  has_many :samples
  has_many :object_types

  validates :name, presence: true
  validates :description, presence: true

  def export
    attributes
  end

  def required_sample_types st_list=[]

    field_types.select { |ft| ft.ftype == 'sample' }.each do |ft|

      ft.allowable_field_types.each do |aft|

        if aft.sample_type && !st_list.member?(aft.sample_type)
          st_list << aft.sample_type
          st_list = aft.sample_type.required_sample_types(st_list)
        end

      end

    end

    st_list

  end

  def inconsistencies raw_sample_type

    results = []

    unless name == raw_sample_type[:name] 
      results << "names #{name} and #{raw_sample_type[:name]} do not agree."
    end

    unless description == raw_sample_type[:description]
      results << "#{name} descriptions do not agree"
      return false 
    end

    raw_sample_type[:field_types].each do |rft|
      fts = field_types.select { |ft| ft.name == rft[:name] }
      if fts.length == 1 
        results += fts[0].inconsistencies(rft, name)
      else
        results << "#{name} does not have a field named #{rst[:name]}, although the imported version of this sample type does."
      end
    end

    results

  end

  def self.compare_and_upgrade raw_sample_types

    notes = []
    inconsistencies = []
    make = []

    raw_sample_types.each do |rst|

      st = find_by_name(rst[:name])

      if st
        note = "Found sample type '#{rst[:name]}'"
        sample_type_inconsistencies = st.inconsistencies rst
        inconsistencies += sample_type_inconsistencies
        if !sample_type_inconsistencies.any? 
          note += " with same definition as imported type."
          notes << note
        else
          note += " which not consistent with the imported sample type of the same name."
          inconsistencies << note
        end
      else
        notes << "Sample type named '#{rst[:name]}' not found. It will be eventually have to be created from the imported definition."
        make << rst
      end

    end

    unless inconsistencies.any?

      # make sample types
      make.each do |rst|
        st = SampleType.create_from_raw rst
        notes << "Created new sample type #{st.name} with id #{st.id}"
      end

      # make allowable field types (assumes sample type shave been made)
      make.each do |rst|
        st.create_afts_from_raw rst
      end

    end

    { notes: notes, inconsistencies: inconsistencies }

  end

  def self.create_from_raw raw_sample_type 

    st = SampleType.new name: raw_sample_type[:name], description: raw_sample_type[:description]
    st.save

    rst[:field_types].each do |rft|

      ft = FieldType.new({
        parent_id: st.id,
        array: rst[:array],
        choices: rst[:choices],
        required: rst[:required],
        ftype: rst[:ftype],
        role: rst[:role],
        routing: rst[:routing]
       })

      ft.save

    end

  end

  def create_afts_from_raw raw_sample_type

    field_types.each do |ft|
      rst[:field_types].each do |rst|
        if ft.name == rst[:name]
          (0..rst[:sample_types].length-1).each do |i|
            st = SampleType.find_by_name(rst[:sample_types][i])
            ot = ObjectType.find_by_name(rst[:sample_types][i])            
            aft = AllowableFieldType.new({
              field_type_id: ft.id, 
              sample_type_id: st ? st.id : nil, 
              object_type_id: ot ? ot.id : nil
            })
            aft.save
          end
        end
      end
    end

  end

end





