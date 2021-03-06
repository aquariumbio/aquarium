# typed: false
# frozen_string_literal: true

module HasTiming

  def timing
    t = Timing.where(parent_class: self.class.to_s, parent_id: id)
    return t[0] if t.length == 1

    nil
  end

  def timing=(data)
    t = timing
    t ||= Timing.new parent_class: self.class.to_s, parent_id: id
    t.start = data[:start]
    t.stop = data[:stop]
    t.days_of_week = data[:days_of_week] if data[:days_of_week]
    t.days = data[:days] if data[:days]
    t.active = data[:active]
    t.save
  end

end
