# frozen_string_literal: true

module CodeHelper

  def code(name = nil)

    Code.where(parent_id: id, parent_class: self.class.to_s, name: name)
        .first(order: 'id desc', limit: 1)

  end

  def new_code(name, content, user)

    if code(name)

      raise "Could not save code: #{name} already exists for #{self.class} #{id}"

    else

      f = Code.new(
        parent_id: id,
        parent_class: self.class.to_s,
        name: name,
        content: content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''),
        user_id: user.id
      )

      f.save
      raise f.errors.full_messages.to_s unless f.errors.empty?
      f

    end

  end

end
