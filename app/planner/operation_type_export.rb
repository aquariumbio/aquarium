module OperationTypeExport

  def nl
    '\n'
  end

  def export

    {

      name: name,
      category: category,
      deployed: false,
      on_the_fly: on_the_fly ? true : false,

      field_types: field_types.select { |ft| ft.role }.collect { |ft|

        {

          role: ft.role, 
          name: ft.name,
          sample_types: ft.allowable_field_types.collect { |aft| aft.sample_type ? aft.sample_type.name : "" },
          object_types: ft.allowable_field_types.collect { |aft| aft.object_type ? aft.object_type.name : "" },
          part: ft.part ? true : false,
          array: ft.array ? true : false,
          routing: ft.routing

        }

      },

      protocol: protocol ? protocol.content : "",
      precondition: precondition ? precondition.content : "",
      cost_model: cost_model ? cost_model.content : "",
      documentation: documentation ? documentation.content : ""

    }

  end

  def self.included(base)
    base.extend(ClassMethods)
  end  

  def copy
    ot = OperationType.import(export)
    ot.name += " (copy)"
    ot.category = category
    ot.deployed = false
    ot.save
    ot
  end

  module ClassMethods

    def import obj

      ot = OperationType.new name: obj[:name], category: obj[:category], deployed: obj[:deployed], on_the_fly: obj[:on_the_fly]
      ot.save
    
      raise "Could not save operation type: " + ot.errors.full_messages.join(', ') unless ot.errors.empty?   

      if obj[:field_types]
        obj[:field_types].each do |ft|
          ot.add_io ft[:name], ft[:sample_types], ft[:object_types], ft[:role], part: ft[:part], array: ft[:array], routing: ft[:routing]
        end
      end

      ot.new_code 'protocol', obj[:protocol]
      ot.new_code 'precondition', obj[:precondition]
      ot.new_code 'cost_model', obj[:cost_model]
      ot.new_code 'documentation', obj[:documentation]

      ot

    end

    def import_list op_type_list

      op_type_list.each do |ot|
        import ot
      end

    end

    def export_all filename=nil

      ots = OperationType.all.collect { |ot| ot.export }

      if filename
        File.write(filename, ots.to_json)
      end

      ots

    end  

    def import_from_file filename

      import_list(JSON.parse(File.open(filename, "rb").read, symbolize_names: true))
      
    end

  end

end
