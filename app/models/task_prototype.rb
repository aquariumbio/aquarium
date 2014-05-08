class TaskPrototype < ActiveRecord::Base

  attr_accessible :description, :name, :prototype, :status_options
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

end
