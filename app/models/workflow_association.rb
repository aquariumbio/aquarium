class WorkflowAssociation < ActiveRecord::Base

  attr_accessible :item_id, :process_id, :sample_id, :thread_id

  belongs_to :workflow_thread, foreign_key: :thread_id

  def thread
    workflow_thread
  end

end
