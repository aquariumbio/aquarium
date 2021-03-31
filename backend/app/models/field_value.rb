# frozen_string_literal: true

# field_values table
class FieldValue < ActiveRecord::Base
  # get outputs and inputs for an operation
  def self.outputs_inputs(operation_id)
    sql = "
      select fv.id, fv.role, fv.name, s.id as 'sample_id', s.name as 'sample_name', ot.name as 'object_type_name'
      from field_values fv
      left join samples s on s.id = fv.child_sample_id
      left join items i on i.id = fv.child_item_id
      left join object_types ot on ot.id = i.object_type_id
      where parent_class = 'Operation' and parent_id = #{operation_id}
      order by fv.role = 'input', fv.name, fv.id
    "
    outputs_inputs = FieldValue.find_by_sql sql

    outputs = []
    inputs = []
    outputs_inputs.each do |oi|
      oi.role == 'input' ? inputs << oi : outputs << oi
    end

    return outputs, inputs
  end
end
