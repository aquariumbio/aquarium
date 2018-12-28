

class Timing < ActiveRecord::Base

  attr_accessible :parent_class, :parent_id, :start, :stop, :days, :active

  def days_of_week

    (JSON.parse days)
  rescue StandardError => e
    []

  end

  def days_of_week=(list)

    self.days = list.to_json
    save

  end

  def export
    {
      start: start,
      stop: stop,
      days: days,
      active: active
    }
  end

end
