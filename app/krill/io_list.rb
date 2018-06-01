

module IOList

  def items
    collect(&:item)
  end

  def item_ids
    collect { |io| io.item.id }
  end

  def samples
    collect(&:sample)
  end

  def sample_ids
    collect { |io| io.sample.id }
  end

  def collections
    collect(&:collection)
  end

  def collection_ids
    collect { |io| io.collection.id }
  end

  def rows
    collect(&:row)
  end

  def columns
    collect(&:column)
  end

  def rcs
    collect { |io| [io.row, io.column] }
  end

end
