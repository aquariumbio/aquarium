#
# For PDL interpreter, need to know item info
#

class PdlItem

  attr_reader :object, :item

  # object info
  # item info

  def initialize object_info, item_info
    @object = object_info
    @item = item_info
  end

  def to_s
    "PDL Item: #{@object[:name]} taken from location #{@item[:location]}"
  end

end
