

class Library < ActiveRecord::Base

  include CodeHelper

  attr_accessible :name, :category, :layout

  validates :name, presence: true
  validates :category, presence: true


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
