module Krill

  module OperationList

    # Begin building a table from {OperationList}
    # @param opts [Hash]
    # @option opts [Bool] :errored Include {Operation}s with status "error"
    # @example Make a table for pipetting primers into a stripwell for PCR
    #  table operations.start_table
    #    .output_collection("Fragment", heading: "Stripwell")
    #    .custom_column(heading: "Well") { |op| op.output("Fragment").column + 1 }
    #    .input_item(FWD, heading: "Forward Primer, 2.5 µL", checkable: true)
    #    .input_item(REV, heading: "Reverse Primer, 2.5 µL", checkable: true)
    #  .end_table
    # @return {Array} extended with {OperationList}
    def start_table opts={errored:false}
      @table = Table.new
      self
    end

    # Finish building a table
    # @see #start_table
    def end_table
      @table
    end

    def property op, method_name, name, role, checkable

      fv = op.get_field_value name, role

      if checkable
        fv ? { content: fv.send(method_name), check: true } : "?"        
      else
        fv ? fv.send(method_name) : "?"
      end

    end

    # Add column with input/output {Item} ids
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option opts [String] Column heading (defaults to input/output name)
    # @option opts [Bool] Column cells can be clicked
    # @see #input_item
    # @see #output_item
    def item name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Item ID (#{role})", running.collect { |op|
            property op, :child_item_id, name, role, opts[:checkable]
          })
      self
    end

    # Add column with input/output {Sample} ids
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option opts [String] Column heading (defaults to input/output name)
    # @option opts [Bool] Column cells can be clicked
    # @see #input_sample
    # @see #output_sample
    def sample name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Sample ID (#{role})", running.collect { |op|
            property op, :child_sample_id, name, role, opts[:checkable]
          })
      self
    end    

    # Add column with input/output {Collection} ids
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option opts [String] Column heading (defaults to input/output name)
    # @option opts [Bool] Column cells can be clicked
    # @see #input_collection
    # @see #output_collection
    def collection name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Collecton ID (#{role})", running.collect { |op|
        property op, :child_item_id, name, role, opts[:checkable]
      })
      self
    end

    # Add column with input/output row (if part of a {Collection})
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option opts [String] Column heading (defaults to input/output name)
    # @option opts [Bool] Column cells can be clicked
    # @see #input_row
    # @see #output_row
    def row name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Row (#{role})", running.collect { |op|
        property op, :row, name, role, opts[:checkable]
      })
      self      
    end

    # Add column with input/output column (if part of a {Collection})
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option opts [String] Column heading (defaults to input/output name)
    # @option opts [Bool] Column cells can be clicked
    # @see #input_column
    # @see #output_column
    def column name, role, opts={}
      @table.add_column( opts[:heading] || "#{name} Column (#{role})", running.collect { |op|
        property op, :column, name, role, opts[:checkable]
      })
      self      
    end    

    # Add column with custom content
    # @param opts [Hash]
    # @option opts [String] Column heading
    # @option opts [Bool] Column cells can be clicked
    def custom_column opts={heading: "Custom Column", checkable: false }, &block
      @table.add_column opts[:heading], running.collect(&block).collect { |x| 
        opts[:checkable] ? ({ content: x, check: true }) : x
      }
      self
    end

    def operation_id opts={heading: "Operation ID", checkable: false }
      @table.add_column opts[:heading], running.collect { |op| 
        op.id
      }
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