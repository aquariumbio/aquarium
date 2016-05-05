class Parameter < ActiveRecord::Base

  attr_accessible :key, :value, :description

  def self.make key, value
    p = Parameter.new key: key, value: value, description: "Edit me"
    p.save
    p
  end

  def self.get_float key
    p = Parameter.find_by_key(key)
    if p
      p.value.to_f
    else
      p = Parameter.make key, "0.0"
      p.value.to_f
    end
  end

  def self.get_string key
    p = Parameter.find_by_key(key)
    if p
      p.value
    else
      p = Parameter.make key, ""
      p.value
    end
  end

  def self.get key
    get_string key
  end

end
