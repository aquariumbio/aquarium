# frozen_string_literal: true

# operations table
class Operation < ActiveRecord::Base
  def self.pending_operations(operation_ids)
    sql = "select id, operation_type_id from operations where id in ( #{operation_ids.join(',')} ) and status = 'pending'"
    operations = Operation.find_by_sql sql
  end

  def self.distinct_operation_types(operation_ids, status)
    sql = "select distinct operation_type_id from operations where id in ( #{operation_ids.join(',')} ) and status = ?"
    distinct = Operation.find_by_sql [sql, status]
  end

  def self.operations_for_category_type_status(category, type, status)
    sql = "
      select o.id, pa.plan_id, u.name, o.status, o.updated_at
      from operation_types ot
      inner join operations o on o.operation_type_id = ot.id
      inner join plan_associations pa on pa.operation_id = o.id
      inner join users u on u.id = o.user_id
      where ot.category = ? and ot.name = ? and o.status = ?
      order by o.updated_at desc
    "
    operations = Operation.find_by_sql [sql, category, type, status]

    # Loop on operations to get details
    # NOTE: This is a big N+1 problem
    results = []
    operations.each do |o|
      operation_id = o.id

      # get outputs and inputs for operation
      outputs, inputs = FieldValue.outputs_inputs(operation_id)

      # get data_associations for operation
      data_associations = DataAssociation.data_associations(operation_id)

      results << { id: o.id, plan_id: o.plan_id, name: o.name, status: o.status, updated_at: o.updated_at, inputs: inputs, outputs: outputs, data_associations: data_associations }
    end
    results
  end

  def self.set_status_for_ids(status, ids)
    set = sanitize_sql(['status = ?', status])
    sql = "update operations set #{set} where id in ( #{ids.join(',')} )"
    Operation.connection.execute sql
  end

  def self.set_status_for_job(status, job_id)
    set = sanitize_sql(['status = ?', status])
    sql = "update operations set #{set} where id in ( select operation_id from job_associations where job_id = #{job_id} )"
    Operation.connection.execute sql
  end

  def self.operation_from_job(operation_id, job_id)
    sql = "
      select o.*
      from operations o
      inner join job_associations ja on ja.job_id = #{job_id} and ja.operation_id = #{operation_id}
      where o.id = #{operation_id}
    "
    operation = (Operation.find_by_sql sql)[0]
  end
end
