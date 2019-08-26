# frozen_string_literal: true

class ProtocolSummary

  attr_reader :protocol

  def initialize(attr)
    @protocol = attr[:protocol]
  end

end
