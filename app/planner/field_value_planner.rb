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
    wires_as_source.create to_id: fv.id, active: true
  end

  def add_predecessor fv
    # puts "adding predecessor #{fv} to #{self}"
    wires_as_dest.create from_id: fv.id, active: true
  end  

  def sample_type
    if child_sample
      child_sample.sample_type    
    end
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

  def operation
    Operation.find(parent_id)
  end

  def satisfied_by_environment

    case val

    when Sample

      if object_type

        if object_type.handler == 'collection' && field_type.part
         
          collections = Collection.containing(val, object_type).reject { |c| c.deleted? }

          # print "  While Looking for '#{val.id}: #{val.name}' as part of a collection of type #{object_type.name}"            

          if collections.empty?
            # puts "  ... found nothing"            
            return false
          else
            # puts "  ... found collection #{collections[0].id} at #{collections[0].location} with matrix #{collections[0].matrix}"
            self.child_item_id = collections[0].id
            self.save
            return true
          end

        else

          # print "Checking whether input #{name} #{val.name} (#{object_type.name}) needs to be made ... "      
          items = val.items.select { |i| !i.deleted? && i.object_type_id == object_type.id }
          if items.length > 0
            # puts "found #{items[0].object_type.name} #{items[0].id}"
            self.child_item_id = items[0].id
            self.save        
            true
          else
            # puts "not found"
            false
          end

        end

      else
        false
      end

    else
      false
    end

  end

  def satisfies fv

    # puts "\e[93mComparing #{self.child_sample.name} (#{self.object_type.name}) with #{fv.child_sample.name} (#{fv.object_type.name})\e[39m"

    if child_sample_id == fv.child_sample_id && object_type == fv.object_type && field_type.part == fv.field_type.part
      puts "   \e[93mFound operation that already outputs #{fv.child_sample.name} (#{fv.object_type.name}).\e[39m"
      return true
    else
      return false
    end

  end

end