

class Library < ActiveRecord::Base

  include CodeHelper

  attr_accessible :name, :category, :layout

  validates :name, presence: true
  validates :category, presence: true

  validates :name, uniqueness: { 
    scope: :category, 
    case_sensitive: false, 
    message: "Library names must be unique within a given category. When importing, consider first moving existing libraries to a different category"
  }  

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
      lib.new_code 'source', obj[:code_source], user

      issues = { notes: [], inconsistencies: [] }
      issues
  end
end
