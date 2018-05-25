module Lang

  class Scope

    def time

      t = Time.now

      return {
        seconds: t.sec,
        minutes: t.min,
        hours: t.hour,
        day: t.day,
        weekday: Date::DAYNAMES[t.wday],
        month: Date::MONTHNAMES[t.month],
        year: t.year
      }

    end

  end

end
