class TaskPrototype < ActiveRecord::Base

  attr_accessible :description, :name, :prototype, :status_options, :validator, :cost
  has_many :tasks

  validates :name, :presence => true
  validates_uniqueness_of :name
  validates :description, :presence => true
  validate :legal_json
  validate :legal_options

  def legal_json

    okay = true

    begin
      result = JSON.parse self.prototype
    rescue Exception => e
      okay = false      
    end

    errors.add(:json, "Error parsing JSON in prototype. #{e.to_s}") unless okay

    return okay

  end

  def prototype_hash
    begin
      result = JSON.parse self.prototype, symbolize_names: true
    rescue Exception => e
      result = {}
    end
    result
  end

  def legal_options

    okay = true

    begin
      result = JSON.parse self.status_options
    rescue Exception => e
      okay = false      
    end

    if result.class != Array || ( result.select { |a| a.class != String } ) != []
      okay = false
    end

    errors.add(:status, "Status options should be a json array of strings.") unless okay

    return okay

  end

  def status_option_list

    JSON.parse self.status_options

  end

  def export
    attributes
  end

  def after_save
    self.validator
  end

end
