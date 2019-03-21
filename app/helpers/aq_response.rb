class AqResponse < Hash

  def self.ok extras = {}
    AqResponse.new.ok extras
  end

  def self.error msg, error = nil
    AqResponse.new.error(msg, error)
  end

  def initialize
    self[:result] = nil
    self[:message] = nil
    self[:error] = nil
  end

  def ok extras = {}
    self[:result] = "ok"
    self.merge! extras
    self
  end

  def error msg, error = nil
    self[:result] = "error"
    self[:message] = msg
    self[:error] = error.to_s
    self
  end

  def more stuff
    self.merge! stuff
    self
  end

end
