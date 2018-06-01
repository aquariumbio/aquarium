

class JobAssociation < ActiveRecord::Base

  attr_accessible :job_id, :operation_id

  belongs_to :job
  belongs_to :operation

end
