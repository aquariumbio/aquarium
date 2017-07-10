module CodeHelper

  def code name=nil

    q = Code.where(parent_id: self.id, parent_class: self.class.to_s,child_id: nil)

    if name
      cs = q.where(name: name)
      if cs.empty?
        nil
      else
        cs[0]
      end
    else
      q
    end

  end

  def new_code name, content

    if code(name)

      raise "Could not save code: #{name} already exists for #{self.class} #{self.id}"

    else

      f = Code.new(
        parent_id: self.id, 
        parent_class: self.class.to_s, 
        name: name, 
        content: content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') 
      )

      f.save
      raise f.errors.full_messages.to_s unless f.errors.empty?
      f

    end

  end

end
