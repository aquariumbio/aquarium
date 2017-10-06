# Associates and manages {DataAssociation}s

module DataAssociator 

  ########################
  # Getters 
  #

  # Return all {DataAssociation}s
  # @param key [String] Select by this key
  # @return [Array<DataAssociation>]
  def data_associations key=nil
    if key
      DataAssociation.includes(:upload).where(parent_id: id, parent_class: self.class.to_s, key: key.to_s)
    else
      DataAssociation.includes(:upload).where(parent_id: id, parent_class: self.class.to_s)
    end      
  end

  # Return Hash of {DataAssociation}s
  # @return [Hash]
  def associations
    h = HashWithIndifferentAccess.new
    data_associations.each { |da|
      h[da.key] = da.value
    }
    h
  end 

  # @see #get
  def get_association key
    das = data_associations key
    das.length >= 1 ? das[0] : nil
  end

  # Get {DataAssociation} by key
  # @param key [String]
  # @return [DataAssociation]
  def get key
    da = get_association key
    da ? da.full_object[key] : nil
  end

  # Get {Upload} from {DataAssociation} by key
  def upload key
    da = get_association key
    da ? da.upload : nil
  end

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

  # Add {DataAssociation}
  # @param key [String, Symbol]
  # @param value [Object]
  # @param upload [Upload]
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

  # Called if key already exists
  # @see #associate
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
