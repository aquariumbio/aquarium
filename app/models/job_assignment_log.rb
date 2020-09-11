class JobAssignmentLog < ActiveRecord::Base

  attr_accessible :job_id, :user_id

  # GET CURRENT ASSIGNMENT FROM THE VIEW
  # NOTE: THE VIEW GETS THE LATEST ASSIGNMENT FOR EACH JOB_ID (AS DEFINED BY UPDATED_AT)
  def self.get_assignment(job_id)
    sql = "
      select id, job_id, created_at, by_name, by_login, to_name, to_login
      from view_job_assignments
      where job_id = #{job_id}
      limit 1
    "
    (JobAssignmentLog.find_by_sql sql)[0]
  end

end
