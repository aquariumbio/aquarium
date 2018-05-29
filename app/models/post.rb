# frozen_string_literal: true

class Post < ActiveRecord::Base

  include ActionView::Helpers::DateHelper

  attr_accessible :content, :parent_id, :user_id

  belongs_to :user
  has_many :post_associations

  has_many :responses, class_name: 'Post', foreign_key: 'parent_id'
  belongs_to :parent,  class_name: 'Post'

  default_scope eager_load(:user, responses: %i[user post_associations], post_associations: %i[job task item sample])

  after_create :update_root

  self.per_page = 10

  class Protocol

    attr_reader :protocol, :sha

    def initialize(attr)
      @protocol = attr[:protocol]
      @sha = attr[:sha]
    end

  end

  def topic_info?
    post_associations != []
  end

  def topic_info

    info = []
    post_associations.each do |pa|
      info.push pa.info
    end

    info

  end

  def as_json

    j = {
      id: id,
      parent_id: parent_id,
      content: content,
      created_at: created_at,
      nice_date: time_ago_in_words(created_at) + ' ago',
      username: user ? user.name : '?',
      login: user ? user.login : '?',
      user_id: user ? user.id : '-1',
      responses: responses.sort.collect(&:as_json).reverse
    }

    j = j.merge(topic_info: topic_info) if topic_info?

    j

  end

  private

  def update_root

    if parent
      p = parent
      p = p.parent until p.parent_id.nil?
      p.touch
    end

  end

end
