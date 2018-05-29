# frozen_string_literal: true

class ProtocolSummary

  attr_reader :protocol, :sha

  def initialize(attr)
    @protocol = attr[:protocol]
    @sha = attr[:sha]
  end

  def num_posts
    PostAssociation.where(sha: @sha).count
  end

end
