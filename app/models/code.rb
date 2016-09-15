class Code < ActiveRecord::Base

  attr_accessible :name, :content, :parent_id, :parent_class, :child_id

  def commit new_content

    c = Code.new(
      parent_id: self.parent_id, 
      parent_class: self.parent_class, 
      name: self.name, 
      content: new_content
    )

    c.save
    self.child_id = c.id
    self.save
    c

  end

  def versions  
    Code.where(parent_id: self.parent_id, parent_class: self.parent_class, name: self.name)
  end

  def parent
    codes = Code.where(child_id: self.id)
    if codes.empty?
      nil
    else
      codes[0]
    end
  end

end