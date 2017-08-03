module Serialize

  def self.serialize_fv fv

    rfv = {}
    FieldValue.attribute_names.each { |name| rfv[name] = fv[name] }
    rfv

  end

  def self.serialize plan

    ops = plan.operations

    op_ids = ops.collect { |o| o["id"] }

    operation_types = OperationType.where(id: ops.collect { |o| o["operation_type_id"] }).as_json

    field_types = FieldType.includes(allowable_field_types: [ :sample_type, :object_type ])
                        .where(parent_class: "OperationType", parent_id: operation_types.collect { |ot| ot["id"] })
                        .collect { |ft| ft.as_json }


    operation_types.each do |ot|
      ot["field_types"] = field_types.select { |ft| ft["parent_id"] == ot["id"] }
    end

    field_values = FieldValue
                   .where(parent_class: "Operation", parent_id: op_ids)
                   .collect { |fv| self.serialize_fv fv }

    fids = field_values.collect { |fv| fv["id"] }

    wires = Wire.where("from_id in (?) OR to_id in (?)", fids, fids)

    field_values.each do |fv|
      fts = field_types.select { |ft| ft['id'] == fv['field_type_id'] }
      if fts.length == 1 
        fv['field_type'] = fts[0]
        # fts[0][:allowable_field_types].each do |aft|
        #   if aft['id'] == fv['allowable_field_type_id']
        #     fv['aft'] = aft
        #   end
        # end
      end
    end

    sops = ops.as_json

    sops.each do |op|
      op["operation_type"] = operation_types.select { |ot| ot["id"] == op["operation_type_id"] }[0]
      op["field_values"]  = field_values.select { |fv| fv["parent_id"] == op["id"] }
    end

    {
      id: plan.id,
      name: plan.name,
      user_id: plan.user_id,
      created_at: plan.created_at,
      updated_at: plan.updated_at,
      status: plan.status,
      operations: sops,
      wires: wires
    }

  end

end

