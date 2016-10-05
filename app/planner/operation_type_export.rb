module OperationTypeExport

  def nl
    '\n'
  end

  def export

    {

      name: name,
      category: category,
      deployed: deployed ? true : false,
      on_the_fly: on_the_fly ? true : false,

      field_types: field_types.select { |ft| ft.role }.collect { |ft|

        {

          role: ft.role, 
          name: ft.name,
          sample_types: ft.allowable_field_types.collect { |aft| aft.sample_type ? aft.sample_type.name : "" },
          object_types: ft.allowable_field_types.collect { |aft| aft.object_type ? aft.object_type.name : "" },
          part: ft.part ? true : false,
          array: ft.array ? true : false

        }

      },

      protocol: protocol.content,
      cost_model: cost_model.content,
      documentation: documentation.content

    }

  end

  def self.included(base)
    base.extend(ClassMethods)
  end  

  module ClassMethods

    def import obj

      ot = OperationType.new name: obj[:name], category: obj[:category], deployed: obj[:deployed]
      ot.save

      if obj[:field_types]
        obj[:field_types].each do |ft|
          ot.add_io ft[:name], ft[:sample_types], ft[:object_types], ft[:role], part: ft[:part], array: ft[:array]
        end
      end

      ot.new_code 'protocol', obj[:protocol]
      ot.new_code 'cost_model', obj[:cost_model]
      ot.new_code 'documentation', obj[:documentation]

      ot

    end

  end

end
