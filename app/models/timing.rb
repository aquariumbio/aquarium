class Timing < ActiveRecord::Base

  attr_accessible :parent_class, :parent_id, :start, :stop, :days

  def days_of_week

    begin
      return(JSON.parse self.days)
    rescue Exception => e
      return []
    end

  end

  def days_of_week= list

    self.days = list.to_json
    self.save

  end

end