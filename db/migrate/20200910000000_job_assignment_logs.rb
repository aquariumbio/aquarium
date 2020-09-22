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

    add_foreign_key :job_assignment_logs, :jobs, on_delete: :cascade
    add_foreign_key :job_assignment_logs, :users, column: "assigned_by", on_delete: :cascade
    add_foreign_key :job_assignment_logs, :users, column: "assigned_to", on_delete: :cascade
    change_column_null :job_assignment_logs, :created_at, false
    change_column_null :job_assignment_logs, :updated_at, false

    execute <<-SQL
      create view view_job_assignments as
      select jal.*, j.pc, ub.name as 'by_name', ub.login as 'by_login', ut.name as 'to_name', ut.login as 'to_login'
      from job_assignment_logs jal
      inner join (
        select max(id) as 'id'
        from job_assignment_logs
        group by job_id
      ) ij on ij.id = jal.id
      inner join jobs j on j.id = jal.job_id
      inner join users ub on ub.id = jal.assigned_by
      inner join users ut on ut.id = jal.assigned_to
    SQL

  end

end
