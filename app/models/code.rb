class Code < ActiveRecord::Base

  attr_accessible :name, :content, :parent_id, :parent_class, :user_id

  def commit new_content, user

    c = Code.new(
      parent_id: self.parent_id, 
      parent_class: self.parent_class, 
      name: self.name, 
      content: new_content,
      user_id: user.id
    )

    c.save
    c

  end

  def versions
    Code.where(parent_id: self.parent_id, parent_class: self.parent_class, name: self.name)
  end

end