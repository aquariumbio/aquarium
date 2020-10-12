class ViewJobAssignment < ActiveRecord::Base

  # DEFINE THE PRIMARY KEY
  self.primary_key = :id

  # MAKE TABLE READ ONLY
  after_initialize :readonly!

  # ALLOWS <VIEW>.JOB
  belongs_to :job

  # DO NOT SET THESE BECAUSE WE ARE GETTING ALL THE INFO WE NEED IN THE VIEW ITSELF
  # belongs_to :assigned_by_user, class_name: "User", foreign_key: "assigned_by"
  # belongs_to :assigned_to_user, class_name: "User", foreign_key: "assigned_to"

end
