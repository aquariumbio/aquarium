module IOList

  def items
    collect { |io| io.item }
  end

  def item_ids
    collect { |io| io.item.id }
  end  

  def samples
    collect { |io| io.sample }
  end

  def sample_ids
    collect { |io| io.sample.id }
  end  

  def collections
    collect { |io| io.collection }
  end

  def collection_ids
    collect { |io| io.collection.id }
  end  

  def rows
    collect { |io| io.row }
  end

  def columns
    collect { |io| io.column }
  end 

  def rcs
    collect { |io| [io.row,io.column] }
  end 

end