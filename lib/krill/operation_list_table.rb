module Krill

  module OperationList

    def start_table opts={errored:false}
      @table = Table.new
      self
    end

    def end_table
      @table
    end

    def property op, method_name, name, checkable

      fv = op.get_field_value name

      if checkable
        fv ? { content: fv.send(method_name), check: true } : "?"        
      else
        fv ? fv.send(method_name) : "?"
      end

    end

    def item name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Item ID", running.collect { |op|
            property op, :child_item_id, name, opts[:checkable]
          })
      self
    end

    def sample name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Sample ID", running.collect { |op|
            property op, :child_sample_id, name, opts[:checkable]
          })
      self
    end    

    def collection name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Collecton ID", running.collect { |op|
        property op, :child_item_id, name, opts[:checkable]
      })
      self
    end

    def row name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Row", running.collect { |op|
        property op, :row, name, opts[:checkable]
      })
      self      
    end

    def column name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Column", running.collect { |op|
        property op, :column, name, opts[:checkable]
      })
      self      
    end    

    def custom_column heading, &block
      @table.add_column heading, running.collect(&block)
      self      
    end

    def input_item        name, opts={}; item name,       "input", opts;  end
    def output_item       name, opts={}; item name,       "output", opts; end
    def input_sample      name, opts={}; sample name,     "input", opts;  end
    def output_sample     name, opts={}; sample name,     "output", opts; end
    def input_collection  name, opts={}; collection name, "input", opts;  end
    def output_collection name, opts={}; collection name, "output", opts; end
    def input_row         name, opts={}; row name,        "input", opts;  end
    def output_row        name, opts={}; row name,        "output", opts; end
    def input_column      name, opts={}; column name,     "input", opts;  end
    def output_column     name, opts={}; column name,     "output", opts; end

    def get key, opts
      @table.add_column( opts[:heading] || key.to_s, running.collect { |op| 
        { type: opts[:type] || 'number', operation_id: op.id, key: key, default: opts[:default] || 0 }
      })
      self
    end

    def result key, opts={}
      @table.add_column(opts[:heading] || key.to_s, running.collect { |op|
        { content: op.temporary[key], check: opts[:checkable] }
      })
      self
    end
    
  end

end