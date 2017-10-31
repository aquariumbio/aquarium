# Represents the version of a versioned object of "code" 
class Code < ActiveRecord::Base

  attr_accessible :name, :content, :parent_id, :parent_class, :child_id

  # Creates a new `Code` object from this one with the new content.'
  #
  # @param new_content [String] the content of the new version
  # @returns the new version of this object with the new content
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

  # Returns all versions of this object
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