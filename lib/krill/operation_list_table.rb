module Krill

  module OperationList

    def start_table opts={errored:false}
      @table = Table.new
      self
    end

    def end_table
      @table
    end

    def property op, method_name, name
      fv = op.get_field_value name
      fv ? fv.send(method_name) : "?"
    end

    def item name, role
      @table.add_column("#{name} Item ID", running.collect { |op|
            property op, :child_item_id, name
          })
      self
    end

    def collection name, role
      @table.add_column("#{name} Collecton ID", running.collect { |op|
        property op, :child_item_id, name
      })
      self
    end

    def row name, role
      @table.add_column("#{name} Row", running.collect { |op|
        property op, :row, name
      })
      self      
    end

    def column name, role
      @table.add_column("#{name} Column", running.collect { |op|
        property op, :column, name
      })
      self      
    end    

    def custom_column name, &block
      @table.add_column name, running.collect(&block)
      self      
    end

    def input_item        name; item name,       "input";  end
    def output_item       name; item name,       "output"; end
    def input_collection  name; collection name, "input";  end
    def output_collection name; collection name, "output"; end
    def input_row         name; row name,        "input";  end
    def output_row        name; row name,        "output"; end
    def input_column      name; column name,     "input";  end
    def output_column     name; column name,     "output"; end    

  end

end