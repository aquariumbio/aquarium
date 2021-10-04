# frozen_string_literal: true

# job_associations table
class JobAssociation < ActiveRecord::Base
  # get list of <plan_id, updated_at, user.name, operation_id, status> for each job
  # multiple operations per job
  # one plan per operation
  # one user per operation
  # order by operation.upated_at desc, operation.id desc
  def self.job_operations(job_id)
    sql = "
      select ja.id, ja.operation_id, o.updated_at, o.status, pa.plan_id, u.name as 'user_name'
      from jobs j
      inner join job_associations ja on ja.job_id = j.id
      inner join operations o on o.id = ja.operation_id
      inner join plan_associations pa on pa.operation_id = o.id
      inner join users u on u.id = o.user_id
      where j.id = #{job_id}
      order by o.updated_at desc, o.id desc
    "
    job_operations = JobAssociation.find_by_sql sql
  end

  def self.remove_operation_from_job(operation_id, job_id)
    sql = "delete from job_associations where job_id = #{job_id} and operation_id = #{operation_id} limit 1"
    JobAssociation.connection.execute sql
  end
end
