# frozen_string_literal: true

class Take < ActiveRecord::Base
  attr_accessible :item_id, :job_id

  belongs_to :item
  belongs_to :job

end
