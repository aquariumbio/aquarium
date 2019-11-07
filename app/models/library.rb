# frozen_string_literal: true

class Library < ApplicationRecord

  include CodeHelper

  attr_accessible :name, :category, :layout

  validates :name, presence: true
  validates :category, presence: true

  validates :name, uniqueness: {
    scope: :category,
    case_sensitive: false,
    message: 'Library names must be unique within a given category. When importing, consider first moving existing libraries to a different category'
  }

  def source
    code('source')
  end

  def add_source(content:, user:)
    if source
      source.commit(content, user)
    else
      new_code('source', content, user)
    end
  end

  def export
    {
      library: {
        name: name,
        category: category,
        code_source: code('source') ? code('source').content : ''
      }
    }
  end

  def self.import(data, user)
    obj = data[:library]

    lib = Library.new name: obj[:name], category: obj[:category]
    lib.save
    lib.add_source(content: obj[:code_source], user: user)

    issues = { notes: ["Created new library #{obj[:name]} in category #{obj[:category]}"], inconsistencies: [] }
    issues
  end
end
