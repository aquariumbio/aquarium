class PostAssociation < ActiveRecord::Base

  attr_accessible :item_id, :job_id, :post_id, :sample_id, :task_id, :sha

  belongs_to :job
  belongs_to :sample
  belongs_to :item
  belongs_to :task
  belongs_to :post

  def self.get field, key

    if field == :protocol_id
      pas = PostAssociation.includes(post: [:user]).where(:sha => key)
    else
      pas = PostAssociation.includes(post: [:user]).where(field => key)
    end 

    (pas.collect { |pa| pa.post }).reverse

  end

end
