module Krill

  module OperationList

    def protocol= p
      @protocol = p
    end

    def running &block
      select { |op| op.status != "error" }.collect(&block)
    end    

    def errored &block
      select { |op| op.status == "error" }.collect(&block)
    end

    #
    # Get all items. 
    # Error out any operations for which items could not be retrieved.
    # Show item retrieval instructions (unless verbose is false)
    #
    def retrieve opts={interactive:true, method: "boxes"}, &block

      items = []

      each_with_index do |op,i|         
        op_items = []
        op.inputs.each do |input|
          input.retrieve
          if input.child_item_id
              op_items << input.child_item
          else
              op.set_status "error"
              op.associate "input error", "Could not find input #{input.child_sample.name}"
          end                         
        end
        items = items + op_items unless op.status == "error"        
      end

      if block_given?
        @protocol.take items, opts, &Proc.new
      else
        @protocol.take items, opts        
      end

      self

    end

    def output_collections
      @output_collections ||= {}
      @output_collections
    end

    def make opts={errored:false}

      @output_collections = {}

      select { |op| opts[:errored] || op.status != "error" }.each_with_index do |op,i|
        op.outputs.each do |output|
          if output.part?
            output_collections[output.name] ||= output.make_collection(count, 1)
            output.make_part(output_collections[output.name],i,0)
          else
            output.make
          end         
        end
      end

      self

    end

    def store opts={interactive:true,method: "boxes",errored:false,io:"input"}

      items = []

      select { |op| opts[:errored] || op.status != "error" }.each_with_index do |op,i|         
        op.field_values.select { |fv| fv.role == opts[:io] }.each do |input|
          items << input.child_item
        end
      end

      if block_given?
        @protocol.release items, opts, &Proc.new
      else
        @protocol.release items, opts        
      end

      self

    end

    def item_column fv
      fv.name + " Item ID"
    end

    def collection_column fv
      fv.name + " Collection ID"
    end

    def row_column fv
      fv.name + " Row"
    end


    def column_column fv
      fv.name + " Column"
    end

    def io_table role="input"

      t = Table.new

      each_with_index do |op,i|
          
        op.field_values.select { |fv| fv.role == role }.each do |fv|

          if fv.part?
                      
            t.column(fv.name,               fv.name)
             .column(collection_column(fv), collection_column(fv)) 
             .column(row_column(fv),        row_column(fv)) 
             .column(column_column(fv),     column_column(fv)) unless t.has_column? fv.name

            t.set(fv.name,               fv.child_sample.name)          
             .set(collection_column(fv), fv.child_item_id ? fv.child_item_id : "NOT FOUND")
             .set(row_column(fv),        fv.row)
             .set(column_column(fv),     fv.column)                          

          else

            t.column(fv.name,         fv.name)
             .column(item_column(fv), item_column(fv)) unless t.has_column? fv.name

            t.set(fv.name,         fv.child_sample.name)          
             .set(item_column(fv), fv.child_item_id ? fv.child_item_id : "NOT FOUND")

          end
                     
        end
        
        t.append

      end

      t

    end

  end
  
end