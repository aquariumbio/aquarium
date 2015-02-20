class PostAssociation < ActiveRecord::Base

  attr_accessible :item_id, :job_id, :post_id, :sample_id, :task_id, :sha

  belongs_to :job
  belongs_to :sample
  belongs_to :item
  belongs_to :task
  belongs_to :post

  default_scope eager_load(:job,:item,:sample,:task)

  def self.get field, key

    if field == :protocol_id
      pas = PostAssociation.includes(post: [:user]).where(:sha => key)
    else
      pas = PostAssociation.includes(post: [:user]).where(field => key)
    end 

    (pas.collect { |pa| pa.post }).reverse

  end

  def info

    if self.job
      { type: "Job", id: self.job.id, path: "/jobs/#{self.job.id}" }
    elsif self.item
      { type: "Item", id: self.item.id, path: "/Items/#{self.item.id}" }
    elsif self.task
      { type: "Task", id: self.task.id, path: "/Tasks/#{self.task.id}" }
    elsif self.sample
      { type: "Sample", id: self.sample.id, path: "/Samples/#{self.sample.id}" }
    elsif self.sha
      path = Job.limit(1).find_by_sha(self.sha).path
      { type: "Protocol", id: path, path: "/jobs/summary?path=#{path}" }
    else
      {}
    end

  end

end
