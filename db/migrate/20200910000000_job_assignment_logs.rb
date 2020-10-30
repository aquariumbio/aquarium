# typed: false
class JobAssignmentLogs < ActiveRecord::Migration

  def change

    create_table :job_assignment_logs do |t|
      t.references :job
      t.integer :assigned_by
      t.integer :assigned_to
      t.timestamps

      t.index :job_id
      t.index :assigned_by
      t.index :assigned_to
    end

    add_foreign_key :job_assignment_logs, :jobs, on_delete: :cascade                         rescue nil
    add_foreign_key :job_assignment_logs, :users, column: "assigned_by", on_delete: :cascade rescue nil
    add_foreign_key :job_assignment_logs, :users, column: "assigned_to", on_delete: :cascade rescue nil
    change_column_null :job_assignment_logs, :created_at, false
    change_column_null :job_assignment_logs, :updated_at, false

    # VIEW - CURRENT JOB ASSIGNMENT
    execute <<-SQL
      create view view_job_assignment_logs as
      select max(id) as 'id'
      from job_assignment_logs
      group by job_id
    SQL

    execute <<-SQL
      create view view_job_assignments as
      select jal.*, j.pc, ub.name as 'by_name', ub.login as 'by_login', ut.name as 'to_name', ut.login as 'to_login'
      from job_assignment_logs jal
      inner join view_job_assignment_logs vjal on vjal.id = jal.id
      inner join jobs j on j.id = jal.job_id
      inner join users ub on ub.id = jal.assigned_by
      inner join users ut on ut.id = jal.assigned_to
    SQL

    # VIEW - JOB OPERATION TYPE
    execute <<-SQL
      create view view_job_operation_types as
      select distinct ja.job_id, o.operation_type_id, ot.name, ot.category
      from job_associations ja
      inner join operations o on o.id =ja.operation_id
      inner join operation_types ot on ot.id = o.operation_type_id
    SQL

    # VIEW - NUMBER OPERATIONS IN JOB
    execute <<-SQL
      create view view_job_associations as
      select ja.job_id AS job_id, count(*) AS 'n'
      from job_associations ja
      group by ja.job_id
    SQL

  end

end
