# frozen_string_literal: true

# PROCESS INPUT PARAMETERS
module Input

  # RETURN TEXT (NULL IF BLANK)
  def self.text(str)
    str = str.to_s.strip
    str = nil if str == ""

    return str
  end

  # RETURN A NUMBER (NIL OR UNDEFINED RETURNS 0)
  def self.number(n)
    n = n.to_s.to_i

    return n
  end

  # RETURN A BOOLEAN (1 OR NIL)
  def self.boolean(n)
    n = n.to_s.to_i
    n == 1 ? 1 : nil

    return n
  end

end
