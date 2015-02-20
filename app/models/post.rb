class Post < ActiveRecord::Base

  include ActionView::Helpers::DateHelper

  attr_accessible :content, :parent_id, :user_id

  belongs_to :user
  has_many :post_associations

  has_many :responses, class_name: "Post", foreign_key: "parent_id"
  belongs_to :parent,  class_name: "Post"

  default_scope eager_load(:user,responses: [:user,:post_associations],post_associations: [ :job, :task, :item, :sample ])

  after_create :update_root

  class Protocol

    attr_reader :protocol, :sha

    def initialize attr
      @protocol = attr[:protocol]
      @sha = attr[:sha]
    end

  end

  def topic_info?
    self.post_associations != []
  end

  def topic_info

    info = []
    self.post_associations.each do |pa|
      info.push pa.info
    end

    info

  end

  def as_json

   j = {
     :id => self.id,
     :parent_id => self.parent_id,
     :content => "(#{self.id}) " + self.content,
     :created_at => self.created_at,
     :nice_date => time_ago_in_words(self.created_at) + " ago",
     :username => self.user ? self.user.name : "?",
     :login => self.user ? self.user.login : "?",
     :user_id => self.user ? self.user.id : "-1",
     :responses => (self.responses.collect { |p| p.as_json }).reverse
   }

   if self.topic_info?
     j = j.merge( topic_info: self.topic_info )
   end

   j

  end

  private

  def update_root

    p = self.parent
    while p.parent_id != nil
      p = p.parent
    end
    p.touch

  end

end
