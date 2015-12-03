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

  def self.cost_report user_id=nil

    task_prototypes = TaskPrototype.all

    report = (0..11).collect do |i| 

      date = Date.today.at_beginning_of_month - i.month

      task_summaries = TaskPrototype.all.collect do |tp|

        if user_id
          tasks = Task.includes(:task_prototype)
                      .where( "task_prototype_id = ? AND user_id = ? AND ? <= created_at AND created_at < ? ", 
                              tp.id, user_id, date, date + 1.month )
        else
          tasks = Task.includes(:task_prototype)
                      .where( "task_prototype_id = ? AND ? <= created_at AND created_at < ? ", 
                              tp.id, date, date + 1.month )          
        end

        if tasks.length > 0
          number = tasks.collect { |t| t.size }.inject{|sum,x| sum + x }
        else
          number = 0
        end

        {
          name: tp.name,
          number: number,
          cost_per: tp.cost,
          total: tp.cost * number
        }

      end

      { date: date, task_summaries: task_summaries }

    end  

  end

end
