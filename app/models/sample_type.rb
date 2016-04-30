class SampleType < ActiveRecord::Base

  attr_accessible :description, :field1name, :field1type, :field2name, :field2type, :field3name, 
                                :field3type, :field4name, :field4type, :field5name, :field5type, 
                                :field6name, :field6type, :field7name, :field7type, :field8name, :field8type,  
                                :name, :datatype

  has_many :samples
  has_many :object_types

  has_many :field_types, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true

  validate :proper_choices # deprecated

  def save_field_types raw_field_types

    if raw_field_types

      raw_field_types.each do |raw_ft|

        if raw_ft[:id]
          if raw_ft[:deleted]
            FieldType.find(raw_ft[:id]).destroy
          else
            ft = FieldType.find(raw_ft[:id])
            ft.update_attributes(raw_ft.slice(:name,:ftype,:required,:array,:choices))
            ft.save
          end
        else
          ft = self.field_types.create(raw_ft.except :allowable_field_types)
          ft.save
        end

        if raw_ft[:allowable_field_types]

          raw_ft[:allowable_field_types].each do |raw_aft|
            if raw_aft[:id]
              if raw_aft[:deleted]
                AllowableFieldType.find(raw_aft[:id]).destroy
              else
                aft = AllowableFieldType.find(raw_aft[:id])
                aft.update_attributes(raw_aft.slice(:sample_type_id,:object_type_id))
              end
            else
              aft = ft.allowable_field_types.create(raw_aft.slice(:sample_type_id,:object_type_id))
              aft.save
            end
          end

        end

      end

    end

  end

  def create_sample data

    s = self.samples.create data.slice :name, :description, :user_id, :project

    SampleType.transaction do 

      s.save

      self.field_types.each do |ft|

        if ft.required && !data[ft.name.to_sym]
          s.errors.add :required, "Required field #{ft.name} not present" 
         raise ActiveRecord::Rollback                 
        end

        if data[ft.name.to_sym]
          FieldValue.creator s, ft, data[ft.name.to_sym]
        end

      end

    end

    return s

  end

  #############################################################################################
  # Mostly deprecated stuff below

  def fieldname i # deprecated
    n = "field#{i}name".to_sym
    self[n]
  end

  def fieldtype i # deprecated
    t = "field#{i}type".to_sym
    if self[t]
      self[t].split "|"
    else
      []
    end
  end

  def field_index name # deprecated

    i = 1
    while i<=8 && self["field#{i}name".to_sym] != name
      i += 1
    end

    if i<= 8
      i
    else
      nil
    end

  end

  def proper_choices # deprecated

    unary =  ['not used','string','number','url']

    (1..8).each do |i|
      t = self.fieldtype i
      if t.length > 1
        unary.each do |u|
          if t.include? u
            errors.add(:improper_or,"Multiple types can only consist of links to other samples.")
            return
          end
        end
      end
    end

  end

  def export
    attributes
  end

  ####################################################################################################
  # UNUSED WORKFLOW STUFF FROM HERE TO EOF: OKAY TO EVENTUALLY DELETE   

  def datatype_hash
    begin
      JSON.parse(self.datatype,symbolize_names: true)
    rescue Exception => e
      { type: "number", error: "Parse error in JSON. Default data type used." }
    end
  end

  def self.folders 

    { id: -1, 
      name: "All Samples", 
      children: SampleType.all.collect { |st| {
         id: -1, 
         name: st.name.pluralize, 
         sample_type_id: st.id,
         locked: true
        } 
      },
      locked: true
    }

  end

end
