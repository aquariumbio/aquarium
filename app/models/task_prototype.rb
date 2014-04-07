class TaskPrototype < ActiveRecord::Base

  attr_accessible :description, :name, :prototype
  has_many :tasks

  validates :name, :presence => true
  validates_uniqueness_of :name
  validates :description, :presence => true
  validate :legal_json

  def legal_json

    okay = true

    begin
      result = JSON.parse self.prototype
    rescue Exception => e
      okay = false      
    end

    errors.add(:json, "Error parsing JSON in prototype. #{e.to_s}") unless okay

  end

end
