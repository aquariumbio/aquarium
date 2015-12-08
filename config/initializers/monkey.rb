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

class ActiveRecord::Base
  
  def self.import!(record_list)
    raise "record_list not an Array of Hashes" unless record_list.is_a?(Array) && record_list.all? { |rec| rec.is_a? Hash }
    return record_list if record_list.empty?
    # Rails.logger.info "Inserting #{record_list.count} records"
    (1..record_list.count).step(200).each do |start|
      # Rails.logger.info "inserting ids: #{record_list[start-1..start+198].collect { |r| r['id'] }}"
      key_list, value_list = convert_record_list(record_list[start-1..start+198])
      sql = "INSERT INTO #{self.table_name} (#{key_list.join(", ")}) VALUES #{value_list.map {|rec| "(#{rec.join(", ")})" }.join(" ,")}"
      self.connection.insert_sql(sql)
    end
    
    return record_list
  end
  
  def self.convert_record_list(record_list)
    # Build the list of keys
    key_list = record_list.map(&:keys).flatten.map(&:to_s).uniq.sort

    value_list = record_list.map do |rec|
      list = []
      key_list.each {|key| list <<  ActiveRecord::Base.connection.quote(rec[key] || rec[key.to_sym]) }
      list
    end
    
    # If table has standard timestamps and they're not in the record list then add them to the record list
    time = ActiveRecord::Base.connection.quote(Time.now)
    for field_name in %w(created_at updated_at)
      if self.column_names.include?(field_name) && !(key_list.include?(field_name))
        key_list << field_name
        value_list.each {|rec| rec << time }
      end
    end
    
    return [key_list, value_list]

  end

end