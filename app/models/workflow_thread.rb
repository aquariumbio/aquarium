class WorkflowThread < ActiveRecord::Base

  attr_accessible :workflow_id, :process_id, :specification

  has_many :workflow_associations, foreign_key: :thread_id

  def associations
    workflow_associations
  end

  def sample_ids
    (associations.select { |a| a.sample_id }).collect { |a| a.sample_id }
  end

  def spec
    JSON.parse specification, symbolize_names: true
  end

end
