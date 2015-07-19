class TimeSpec  

  def initialize str
    @str = str
    tokenize str
  end

  def tokenize str
    @tokens = str.split(' ')
    @i = 0
  end

  def current
    @tokens[@i]
  end

  def eat s=nil
    if s
      raise "expected #{s} at #{current}" unless current == s
    end
      @i += 1
  end

  def eat_number
    x = current.to_i
    @i += 1
    x
  end

  def eat_time
    p = current.split(":")
    @i += 1
    if p.length == 2
      p[0].to_i.hour + p[1].to_i.minute
    elsif p.length == 3
      p[0].to_i.day + p[1].to_i.hour + p[2].to_i.minute
    else
      "expected d:h:m at #{current}"
    end
  end

  def parse 
    @i = 0
    case current
    when "now", "immediately"
      eat 
      Time.now
    when "day"
      eat
      day = eat_number
      eat "at"
      Time.now.beginning_of_day + (day-1).day + eat_time
    when "today"
      eat
      Time.now.beginning_of_day + eat_time
    else
      duration = eat_time
      case current
      when "from"
        eat
        eat "now"
        Time.now + duration
      when "after"
        eat
        eat "previous"
        Time.now + duration
      else
        raise "could not parse '#{@str}'"
      end
    end
  end
end