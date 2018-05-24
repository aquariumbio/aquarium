class TaskPrototype < ActiveRecord::Base

  attr_accessible :description, :name, :prototype, :status_options, :validator, :cost, :metacol
  has_many :tasks

  validates :name, presence: true
  validates_uniqueness_of :name
  validates :description, presence: true
  validate :legal_json
  validate :legal_options

  def legal_json

    okay = true

    begin
      result = JSON.parse prototype
    rescue Exception => e
      okay = false
    end

    errors.add(:json, "Error parsing JSON in prototype. #{e}") unless okay

    okay

  end

  def prototype_hash
    begin
      result = JSON.parse prototype, symbolize_names: true
    rescue Exception => e
      result = {}
    end
    result
  end

  def legal_options

    okay = true

    begin
      result = JSON.parse status_options
    rescue Exception => e
      okay = false
    end

    okay = false if result.class != Array || (result.reject { |a| a.class == String }) != []

    errors.add(:status, 'Status options should be a json array of strings.') unless okay

    okay

  end

  def status_option_list

    JSON.parse status_options

  end

  def export
    attributes
  end

  def after_save
    validator
  end

  def self.cost_report(user_id = nil)

    task_prototypes = TaskPrototype.all
    users = User.all

    report = (0..11).collect do |i|

      date = Date.today.at_beginning_of_month - i.month
      breakdown = {}
      users.each { |u| breakdown[u.login] = { name: u.name, id: u.id, cost: 0.0 } }

      task_summaries = task_prototypes.collect do |tp|

        tasks = if user_id
                  Task.includes(:task_prototype)
                      .where("status != 'canceled' AND task_prototype_id = ? AND user_id = ? AND ? <= created_at AND created_at < ? ",
                             tp.id, user_id, date, date + 1.month)
                else
                  Task.includes(:task_prototype)
                      .where("status != 'canceled' AND task_prototype_id = ? AND ? <= created_at AND created_at < ? ",
                             tp.id, date, date + 1.month)
                end # if

        number = if !tasks.empty?
                   tasks.collect(&:size).inject { |sum, x| sum + x }
                 else
                   0
                 end # if

        r = {
          id: tp.id,
          name: tp.name,
          number: number,
          cost_per: tp.cost,
          total: tp.cost * number
        }

        unless user_id
          users.each do |u|
            utasks = tasks.select { |t| t.user_id == u.id }
            unless utasks.empty?
              number = tasks.select { |t| t.user_id == u.id }.collect(&:size).inject { |sum, x| sum + x }
              breakdown[u.login][:cost] += tp.cost * number
            end
          end
        end # if

        r

      end # collect task summaries

      { date: date, task_summaries: task_summaries, breakdown: breakdown }

    end # collect dates

  end

end
