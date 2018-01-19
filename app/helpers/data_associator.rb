# Associates and manages {DataAssociation}s

module DataAssociator 

  ########################
  # Getters 
  #

  # Return the {DataAssociation}s for this object that have the given key, or 
  # all associations if no key is given.
  # Includes the upload object for the association if there is one.
  #
  # @param key [String] the key for the association
  # @return [Array<DataAssociation>] the array of associations with the key
  def data_associations key=nil
    if key
      DataAssociation.includes(:upload).where(parent_id: id, parent_class: self.class.to_s, key: key.to_s)
    else
      DataAssociation.includes(:upload).where(parent_id: id, parent_class: self.class.to_s)
    end      
  end

  # Return the Hash of all {DataAssociation}s for this object.
  #
  # @return [Hash] the hash map of all associations for this object
  def associations
    h = HashWithIndifferentAccess.new
    data_associations.each { |da|
      h[da.key] = da.value
    }
    h
  end 

  # Get the {DataAssociation} with the given key for this object.
  #
  # @param key [String] the key for the association
  # @return [DataAssociation] with the key, or `nil`
  def get_association key
    das = data_associations key
    das.length >= 1 ? das[0] : nil
  end

  # Get the {DataAssociation} with the given key for this object.
  #
  # @param key [String] the key for the association
  # @return [DataAssociation] with the key, or `nil`
  def get key
    da = get_association key
    da ? da.full_object[key] : nil
  end

  # Get {Upload} from {DataAssociation} by key.
  #
  # @param key [String] the key for the association
  # @return [Upload] the upload object for the association, `nill` if there is none.
  def upload key
    da = get_association key
    da ? da.upload : nil
  end

  # Return the notes association for this object.
  #
  # @return the notes association for this object
  def notes
    da = get_association :notes
    if da
      da.full_object[:notes]
    else
      associate :notes, ""
      ""
    end
  end

  ##########################
  # Setters
  #

  # Add a {DataAssociation} to this object to a value and an `Upload`, and with the given key.
  # 
  # If an association with the key exists, then the association will be modified (@see modify).
  #
  # @param key [String] the key for the new association
  # @param value [Object] the value for the new association (may be any serializable value)
  # @param upload [Upload] the upload object (default: `nil`)
  # @example Associate concentration with an operation's input
  #   op.input("Fragment").item.associate :concentration, 42
  def associate key, value, upload=nil

    if data_associations(key).empty? 
      da = DataAssociation.new({
        parent_id: id,
        parent_class: self.class.to_s,
        key: key.to_s,
        object: { key => value }.to_json,
        upload_id: upload ? upload.id : nil
      })
      da.save
      unless da.errors.empty?      
        self.errors.add :data_association_error, "Could not save data association named '#{key}': #{da.errors.full_messages.join(', ')}"        
      end
    else
      modify key, value, upload
    end

    self

  end

  # Modifies the existing association for the key.
  # @see #associate
  #
  # @param key [String] the key for the association
  # @param value [Object] the new value for the association (may be any serializable value)
  # @param upload [Upload] the upload object (default: `nil`)
  def modify key, value, upload=nil
    da = get_association key
    if da
      da.object = { key => value }.to_json
      da.upload = upload if upload
      da.save
    else      
      self.errors.add :data_association_error, "Data association named '#{key}' not found."
    end
    self
  end

  # Sets the notes association for this object.
  #
  # @param text [String] the text content of the notes for this object
  def notes= text
    da = get_association :notes
    if da
      da.object = { notes: text.to_s }.to_json
      da.save
    else
      associate :notes, text.to_s
    end    
    text
  end

  # Appends text to the associated notes for this object.
  #
  # @param text [String] the content to be added
  def append_notes text
    da = get_association :notes
    if da
      current = da.full_object[:notes]
      da.object = { notes: current + text.to_s }.to_json
      da.save
    else
      associate :notes, text.to_s
    end    
    text
  end

end
