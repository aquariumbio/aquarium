class TaskNotification < ActiveRecord::Base

  attr_accessible :content, :job_id, :read, :task_id

  belongs_to :task
  belongs_to :job

end
