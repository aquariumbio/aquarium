module FieldValuePlanner

  extend ActiveSupport::Concern

  included do

    has_many :wires

    has_many :wires_as_source, class_name: "Wire", foreign_key: :from_id
    has_many :wires_as_dest, class_name: "Wire", foreign_key: :to_id 

    has_many :successors, through: :wires_as_source, source: :to
    has_many :predecessors, through: :wires_as_dest, source: :from    

  end

  def add_successor fv
    wires_as_source.create to_id: fv.id
  end

  def add_predecessor fv
    wires_as_dest.create from_id: fv.id
  end  

  def unsat
    if @unsat != true && @unsat != false
      @unsat = false
    end
    @unsat
  end

  def sample_type
    child_sample.sample_type    
  end

  def object_type
    st = sample_type
    field_type.allowable_field_types.each do |aft|
      if aft.sample_type == st
        return aft.object_type
      end
    end
    return nil
  end

  def satisfied_by_environment

    case val
    when Sample
      if object_type
        print "Checking whether input #{name} #{val.name} (#{object_type.name}) needs to be made ... "      
        items = val.items.select { |i| !i.deleted? && i.object_type_id == object_type.id }
        if items.length > 0
          puts "found #{items[0].object_type.name} #{items[0].id}"
          true
        else
          puts "not found"
          false
        end
      else
        false
      end
    else
      false
    end

  end

end