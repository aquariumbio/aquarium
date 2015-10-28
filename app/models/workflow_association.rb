class WorkflowAssociation < ActiveRecord::Base

  attr_accessible :item_id, :process_id, :sample_id, :thread_id

  belongs_to :workflow_thread, foreign_key: :thread_id
  belongs_to :sample, foreign_key: :sample_id

  def thread
    workflow_thread
  end

  def role 

    name = "unknown"

    begin

      self.workflow_thread.spec.each do |part|
        if part[:sample].class == String
          name = part[:name] if part[:sample].as_sample_id == sample_id
        elsif part[:sample].class == Array
          (0..part[:sample].length-1).each do |i|
            name = "#{part[:name]}[#{i}]" if part[:sample][i].as_sample_id == sample_id
          end
        end
      end

    rescue Exception => e
      name = "error" #{e}"
    end

    name

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
