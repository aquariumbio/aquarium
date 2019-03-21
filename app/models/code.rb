

# Represents a code object for an operation type.
#
class Code < ActiveRecord::Base
  attr_accessible :name, :content, :parent_id, :parent_class, :user_id

  # Creates a new `Code` object from this one with the new content.'
  #
  # @param new_content [String] the content of the new version
  # @param user [User] the user creating the new version
  # @returns the new version of this object with the new content
  def commit(new_content, user)
    c = Code.new(
      parent_id: parent_id,
      parent_class: parent_class,
      name: name,
      content: new_content,
      user_id: user.id
    )
    c.save
  
    c
  end

  # Creates a Code object using the parent (or owner) and user objects.
  #
  # @param name [String] the name of the new code object
  # @param parent [Object] the object to which the code belongs
  # @param content [String] the code text
  # @param user [User] the user creating this object
  # @return [Code] the created object
  def self.create_from(name:, parent:, content:, user:)
    Code.new(
      name: name,
      content: content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''),
      parent_id: parent.id,
      parent_class: parent.class.to_s,
      user_id: user.id
    )
  end

  # Returns all versions of this object.
  #
  # @return [Code] all objects with the same name and owner (parent)
  def versions
    Code.where(parent_id: parent_id, parent_class: parent_class, name: name)
  end

  # Loads the code content
  def load
    # TODO: check content type is krill before evaluating
    eval(content)
  end

end
