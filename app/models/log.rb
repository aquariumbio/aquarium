# frozen_string_literal: true

class Log < ActiveRecord::Base

  attr_accessible :data, :job_id, :entry_type, :user_id

  belongs_to :user

end
