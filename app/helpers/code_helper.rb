# Mixin for managing code objects associated with an object.
module CodeHelper
  # Return the Code object with the given name.
  #
  # @param name [String] the name for the code
  # @return [Code] the named object if one exists, nil otherwise
  def code(name = nil)
    Code.where(parent_id: id, parent_class: self.class.to_s, name: name)
        .order('id desc')
        .first
  end

  # Add a new code object to this object.
  #
  # @param name [String] the name for the code object
  # @param content [String] the content string for the content code
  # @param user [User] the user creating the code
  def new_code(name, content, user)
    msg = "Could not save code: #{name} already exists for #{self.class} #{id}"
    raise msg if code(name)

    code_object = Code.create_from(
      name: name, parent: self, content: content, user: user
    )
    code_object.save
    raise code_object.errors.full_messages.to_s unless code_object.errors.empty?

    code_object
  end
end
