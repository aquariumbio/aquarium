

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
	  	  code: code ? Library.find(params[:id]).code.content : '' 
	  }
  	}
  end
end
