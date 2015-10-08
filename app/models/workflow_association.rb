class WorkflowAssociation < ActiveRecord::Base

  attr_accessible :item_id, :process_id, :sample_id, :thread_id

  belongs_to :workflow_thread, foreign_key: :thread_id
  belongs_to :sample, foreign_key: :sample_id

  def thread
    workflow_thread
  end

  def role 

    begin

      (self.workflow_thread.spec.find { |part|
        part[:sample].split(':')[0].to_i == sample_id
      })[:name]

    rescue Exception => e
      "unknown #{e}"
    end

  end

  def serializable_hash(options = { })
    h = super(options)
    h[:specification] = self.workflow_thread.spec
    h[:role] = {
      name: self.role,
      workflow_name: self.workflow_thread.workflow.name,
      process_id: self.workflow_thread.process_id
    }
    h
  end  

end
