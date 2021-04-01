# typed: false
class UpdateViewJobAssignments < ActiveRecord::Migration[4.2]
  # View used to get extended user data (including parameters)
  def change
    # NOTE: cannot use a nested query with rake db:migrate, so need to create as 2 separate views

    # Remove current sub-view
    execute <<-SQL
      drop view if exists view_job_assignment_logs
    SQL

    # Replace sub-view
    execute <<-SQL
      create view view_job_assignment_logs as
      select max(id) as 'id'
      from job_assignment_logs
      group by job_id
    SQL

    # Remove current view
    execute <<-SQL
      drop view if exists view_job_assignments
    SQL

    # Replace view
    execute <<-SQL
      create view view_job_assignments as
      select jal.*, j.pc, ub.name as 'by_name', ub.login as 'by_login', ut.name as 'to_name', ut.login as 'to_login'
      from job_assignment_logs jal
      inner join view_job_assignment_logs vjal on vjal.id = jal.id
      inner join jobs j on j.id = jal.job_id
      inner join users ub on ub.id = jal.assigned_by
      inner join users ut on ut.id = jal.assigned_to
    SQL
  end
end
