class Post < ActiveRecord::Base

  include ActionView::Helpers::DateHelper

  attr_accessible :content, :parent_id, :user_id

  belongs_to :user
  has_many :post_associations

  has_many :responses, class_name: "Post", foreign_key: "parent_id"
  belongs_to :parent,  class_name: "Post"

  class Protocol

    attr_reader :protocol, :sha

    def initialize attr
      @protocol = attr[:protocol]
      @sha = attr[:sha]
    end

  end

  def as_json
   {
     :id => self.id,
     :parent_id => self.parent_id,
     :content => self.content,
     :created_at => self.created_at,
     :nice_date => time_ago_in_words(self.created_at) + " ago",
     :username => self.user ? self.user.name : "?",
     :login => self.user ? self.user.login : "?",
     :user_id => self.user ? self.user.id : "-1",
     :responses => (self.responses.collect { |p| p.as_json }).reverse
   }
  end

end
