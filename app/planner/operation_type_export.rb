

module OperationTypeExport

  def nl
    '\n'
  end

  def export

    sample_types = []
    object_types = []

    field_types.select { |ft| ft.role == 'input' || ft.role == 'output' }.collect do |ft|
      ft.allowable_field_types.each do |aft|
        if aft.sample_type
          sample_types << aft.sample_type
          sample_types += aft.sample_type.required_sample_types
        end
        puts sample_types.collect(&:name)
        object_types << aft.object_type if aft.object_type
      end
    end

    sample_types = sample_types.uniq.as_json(methods: [:export_field_types])

    sample_types.each do |st|
      st["field_types"] = st["export_field_types"]
      st.delete "export_field_types"
    end

    object_types = object_types.uniq.as_json(methods: [:sample_type_name])

    # ISSUE: This code misses object types referred to by sub-samples of samples mentioned in the io.

    {

      sample_types: sample_types,

      object_types: object_types,

      operation_type: {

        name: name,
        category: category,
        deployed: false,
        on_the_fly: on_the_fly ? true : false,

        field_types: field_types.select(&:role).collect do |ft|

          {

            ftype: ft.ftype,
            role: ft.role,
            name: ft.name,
            sample_types: ft.allowable_field_types.collect { |aft| aft.sample_type ? aft.sample_type.name : nil },
            object_types: ft.allowable_field_types.collect { |aft| aft.object_type ? aft.object_type.name : nil },
            part: ft.part ? true : false,
            array: ft.array ? true : false,
            routing: ft.routing,
            preferred_operation_type_id: ft.preferred_operation_type_id,
            preferred_field_type_id: ft.preferred_field_type_id,
            choices: ft.choices

          }

        end,

        protocol: protocol ? protocol.content : '',
        precondition: precondition ? precondition.content : '',
        cost_model: cost_model ? cost_model.content : '',
        documentation: documentation ? documentation.content : '',

        timing: timing ? timing.export : nil

      }

    }

  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def copy(user)
    # Choose a name for the copy that is not already used
    exported = export
    original_name = exported[:operation_type][:name]
    counter = 0
    copy_name = original_name + ' (copy)'
    until OperationType.where(category: category, name: copy_name).empty?
      counter += 1
      copy_name = original_name + " (copy #{counter})"
    end
    exported[:operation_type][:name] = copy_name

    ot = OperationType.simple_import(exported, user)
    ot.category = category
    ot.deployed = false
    ot.save
    ot

  end

  module ClassMethods

    def import(data, user)

      issues1 = SampleType.compare_and_upgrade(data[:sample_types] ? data[:sample_types] : [])

      issues2 = if issues1[:inconsistencies].any?
                  { notes: [], inconsistencies: [] }
                else
                  ObjectType.compare_and_upgrade(data[:object_types] ? data[:object_types] : [])
                end

      issues = { notes: issues1[:notes] + issues2[:notes],
                 inconsistencies: issues1[:inconsistencies] + issues2[:inconsistencies] }

      if issues[:inconsistencies].any?
        issues[:notes] << "Operation Type '#{data[:operation_type][:name]}' not imported."
        return issues
      end

      # Add any allowable field_type linkes that resolved to nil before the all sample type
      # and object types were made
      SampleType.clean_up_allowable_field_types(data[:sample_types] ? data[:sample_types] : [])

      # Add any sample_type_ids to object_types now that all sample types have been made
      ObjectType.clean_up_sample_type_links(data[:object_types] ? data[:object_types] : [])

      obj = data[:operation_type]

      ot = OperationType.new name: obj[:name], category: obj[:category], deployed: obj[:deployed], on_the_fly: obj[:on_the_fly]
      ot.save

      raise "Could not save operation type '#{obj[:name]}': " + ot.errors.full_messages.join(', ') + "." unless ot.errors.empty?

      if obj[:field_types]
        obj[:field_types].each do |ft|
          ot.add_io(
            ft[:name], ft[:sample_types], ft[:object_types], ft[:role],
            part: ft[:part],
            array: ft[:array],
            routing: ft[:routing],
            ftype: ft[:ftype],
            preferred_operation_type_id: ft[:preferred_operation_type_id],
            preferred_field_type_id: ft[:preferred_field_type_id]
          )
        end
      end

      ot.new_code 'protocol', obj[:protocol], user
      ot.new_code 'precondition', obj[:precondition], user
      ot.new_code 'cost_model', obj[:cost_model], user
      ot.new_code 'documentation', obj[:documentation], user

      if obj[:timing]
        puts 'Timing: ' + obj[:timing].inspect
        ot.timing = obj[:timing]
        puts '  ==> ' + ot.timing.inspect
      else
        puts 'No Timing?'
      end

      issues[:notes] << "Created new operation type '#{ot.name}'"

      issues[:operation_type] = ot

      issues

    end

    def simple_import(data, user)

      obj = data[:operation_type]

      ot = OperationType.new name: obj[:name], category: obj[:category], deployed: obj[:deployed], on_the_fly: obj[:on_the_fly]
      ot.save

      raise 'Could not save operation type: ' + ot.errors.full_messages.join(', ') unless ot.errors.empty?

      if obj[:field_types]
        obj[:field_types].each do |ft|
          ot.add_io(
            ft[:name], ft[:sample_types], ft[:object_types], ft[:role],
            part: ft[:part],
            array: ft[:array],
            routing: ft[:routing],
            ftype: ft[:ftype],
            preferred_operation_type_id: ft[:preferred_operation_type_id],
            preferred_field_type_id: ft[:preferred_field_type_id]
          )
        end
      end

      ot.new_code 'protocol', obj[:protocol], user
      ot.new_code 'precondition', obj[:precondition], user
      ot.new_code 'cost_model', obj[:cost_model], user
      ot.new_code 'documentation', obj[:documentation], user

      if obj[:timing]
        puts 'Timing: ' + obj[:timing].inspect
        ot.timing = obj[:timing]
        puts '  ==> ' + ot.timing.inspect
      else
        puts 'No Timing?'
      end

      ot

    end

    def import_list(op_type_list)

      op_type_list.each do |ot|
        import ot
      end

    end

    def export_all(filename = nil)

      ots = OperationType.all.collect(&:export)

      File.write(filename, ots.to_json) if filename

      ots

    end

    def import_from_file(filename)

      import_list(JSON.parse(File.open(filename, 'rb').read, symbolize_names: true))

    end

  end

end
