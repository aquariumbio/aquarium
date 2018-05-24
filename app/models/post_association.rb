class PostAssociation < ActiveRecord::Base

  attr_accessible :item_id, :job_id, :post_id, :sample_id, :task_id, :sha

  belongs_to :job
  belongs_to :sample
  belongs_to :item
  belongs_to :task
  belongs_to :post

  default_scope eager_load(:job, :item, :sample, :task)

  def self.get(field, key)

    pas = if field == :protocol_id
            PostAssociation.includes(post: [:user]).where(sha: key)
          else
            PostAssociation.includes(post: [:user]).where(field => key)
          end

    pas.collect(&:post).reverse

  end

  def info

    if job
      { type: 'Job', id: job.id, path: "/jobs/#{job.id}" }
    elsif item
      { type: 'Item', id: item.id, path: "/items/#{item.id}" }
    elsif task
      { type: 'Task', id: task.id, path: "/tasks/#{task.id}" }
    elsif sample
      { type: 'Sample', id: sample.id, path: "/samples/#{sample.id}" }
    elsif sha
      path = Job.limit(1).find_by_sha(sha).path
      id = path.split('/').last
      { type: 'Protocol', id: id, path: "/jobs/summary?path=#{path}" }
    else
      {}
    end

  end

end
