# typed: false
class UpdateViewJobOperationTypes < ActiveRecord::Migration[4.2]
  # View used to get extended user data (including parameters)
  def change
    # Remove current view
    execute <<-SQL
      drop view if exists view_job_operation_types
    SQL

    # Replace view
    execute <<-SQL
      create view view_job_operation_types as
      select distinct j.id as job_id, j.pc, j.created_at, j.updated_at, ot.id as operation_type_id, ot.name, ot.category, ot.deployed, concat(j.id,'-',ot.id) as 'id'
      from jobs j
      inner join job_associations ja on ja.job_id = j.id
      inner join operations o on o.id = ja.operation_id
      inner join operation_types ot on ot.id = o.operation_type_id
    SQL
  end
end
