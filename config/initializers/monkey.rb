 class Array

  def conjoin &block
    temp = self.collect &block
    temp.inject(true) { |a,b| a && b } 
  end

  def disjoin &block
    temp = self.collect &block
    temp.inject(false) { |a,b| a || b } 
  end  

end

class String

  def as_sample_id
    self.split(":")[0].to_i
  end

  def as_container_id
    as_sample_id
  end

end

module ActiveRecord
  class Relation
    def pluck_all(*args)
      args.map! do |column_name|
        if column_name.is_a?(Symbol) && column_names.include?(column_name.to_s)
          "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(column_name)}"
        else
          column_name.to_s
        end
      end

      relation = clone
      relation.select_values = args
      klass.connection.select_all(relation.arel).map! do |attributes|
        initialized_attributes = klass.initialize_attributes(attributes)
        attributes.each do |key, attribute|
          attributes[key] = klass.type_cast_attribute(key, initialized_attributes)
        end
      end
    end
  end
end