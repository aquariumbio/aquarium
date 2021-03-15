# typed: false
class UpdateViewJobAssociations < ActiveRecord::Migration[4.2]
  # View used to get extended user data (including parameters)
  def change
    # Remove current view
    execute <<-SQL
      drop view view_job_associations
    SQL

    # Replace view
    execute <<-SQL
      create view view_job_associations as
      select ja.job_id AS job_id, count(*) AS 'n'
      from job_associations ja
      group by ja.job_id
    SQL
  end
end
