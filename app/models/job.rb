class Job < ActiveRecord::Base
  attr_accessible :arguments, :sha, :state, :user_id
end
