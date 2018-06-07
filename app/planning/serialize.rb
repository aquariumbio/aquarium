

module Serialize

  def self.serialize_fv(fv)

    rfv = {}
    FieldValue.attribute_names.each { |name| rfv[name] = fv[name] }
    rfv

  end

  def self.serialize(plan)

    ops = plan.operations

    op_ids = ops.collect { |o| o['id'] }

    operation_types = OperationType.where(id: ops.collect { |o| o['operation_type_id'] }).as_json

    field_types = FieldType.includes(allowable_field_types: %i[sample_type object_type])
                           .where(parent_class: 'OperationType', parent_id: operation_types.collect { |ot| ot['id'] })
                           .collect(&:as_json)

    operation_types.each do |ot|
      ot['field_types'] = field_types.select { |ft| ft['parent_id'] == ot['id'] }
    end

    field_values = FieldValue
                   .where(parent_class: 'Operation', parent_id: op_ids)
                   .collect { |fv| serialize_fv fv }

    fids = field_values.collect { |fv| fv['id'] }

    wires = Wire.where('from_id in (?) OR to_id in (?)', fids, fids)

    field_values.each do |fv|
      fts = field_types.select { |ft| ft['id'] == fv['field_type_id'] }
      fv['field_type'] = fts[0] if fts.length == 1
    end

    sops = ops.as_json

    sops.each do |op|
      op['field_values'] = field_values.select { |fv| fv['parent_id'] == op['id'] }
    end

    {
      id: plan.id,
      name: plan.name,
      budget_id: plan.budget_id,
      folder: plan.folder,
      user_id: plan.user_id,
      created_at: plan.created_at,
      updated_at: plan.updated_at,
      status: plan.status,
      operations: sops,
      wires: wires,
      layout: plan.layout
    }

  end

  def self.fast_operation_types(dep_only = true)

    ots = OperationType
    ots = ots.where(deployed: true) if dep_only
    ot_ids = ots.collect(&:id)
    fts = FieldType.includes(:allowable_field_types).where(parent_class: 'OperationType', parent_id: ot_ids)
    st_ids = fts.collect { |ft| ft.allowable_field_types.collect(&:sample_type_id) }.flatten
    sts = SampleType.where(id: st_ids)
    ob_ids = fts.collect { |ft| ft.allowable_field_types.collect(&:object_type_id) }.flatten
    obs = ObjectType.where(id: ob_ids)

    ots.collect do |ot|

      sot = ot.as_json

      sot[:field_types] = fts.select { |ft| ft.parent_id == ot.id }
                             .collect do |ft|
        sft = ft.as_json plain: true
        sft[:allowable_field_types] = ft.allowable_field_types.collect do |aft|
          {
            id: aft.id,
            sample_type_id: aft.sample_type_id,
            object_type_id: aft.object_type_id,
            field_type_id: aft.field_type_id,
            sample_type: sts.find { |st| st.id == aft.sample_type_id }.as_json,
            object_type: obs.find { |ot| ot.id == aft.object_type_id }.as_json
          }
        end
        sft
      end

      sot

    end

  end

  def self.item_history(item)

    fvs = FieldValue.where(parent_class: 'Operation', child_item_id: item.id)
    op_ids = fvs.collect(&:parent_id)
    ops = Operation.includes(:jobs, :operation_type, :plan_associations).where(id: op_ids)

    fvs.collect { |fv|
      {
        field_value: fv,
        operation: ops.find { |op| op.id == fv.parent_id }.as_json(include: [:plan_associations, :operation_type, { jobs: { except: :state } }])
      }
    }.reject { |h| !h[:operation] }

  end

end
