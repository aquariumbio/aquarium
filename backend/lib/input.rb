# frozen_string_literal: true

# Process input parameters
module Input

  # Return text (null if blank)
  def self.text(str)
    str = str.to_s.strip
    str = nil if str == ""

    return str
  end

  # Return a number (nil or undefined returns 0)
  def self.number(n)
    n = n.to_s.to_i

    return n
  end

  # Return a boolean (1 or nil)
  def self.boolean(n)
    n = n.to_s.to_i
    n == 1 ? 1 : nil

    return n
  end

end
