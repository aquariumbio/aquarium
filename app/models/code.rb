# Represents the version of a versioned object of "code" 
class Code < ActiveRecord::Base

  attr_accessible :name, :content, :parent_id, :parent_class, :user_id

  # Creates a new `Code` object from this one with the new content.'
  #
  # @param new_content [String] the content of the new version
  # @param user [User] the user creating the new version
  # @returns the new version of this object with the new content
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

  # Returns all versions of this object
  def versions
    Code.where(parent_id: self.parent_id, parent_class: self.parent_class, name: self.name)
  end

end