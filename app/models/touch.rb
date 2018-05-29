# frozen_string_literal: true

class Touch < ActiveRecord::Base
  attr_accessible :item_id, :job_id
  belongs_to :item
  belongs_to :job
  belongs_to :metacol
end
