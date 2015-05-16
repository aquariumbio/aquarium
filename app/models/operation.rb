class Operation < ActiveRecord::Base

  attr_accessible :name, :protocol_path, :specification

  def parse_spec
    JSON.parse specification, symbolize_names: true
  end
  
end
