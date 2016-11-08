module Krill

  module OperationList

    def protocol= p
      @protocol = p
    end

    def collect &block
      ops = super(&block)
      ops.extend(OperationList)
      ops.protocol = @protocol
      ops
    end

    def map &block
      ops = super(&block)
      ops.extend(OperationList)
      ops.protocol = @protocol
      ops
    end

    def select &block
      ops = super(&block)
      ops.extend(OperationList)
      ops.protocol = @protocol
      ops
    end

    def reject &block
      ops = super(&block)
      ops.extend(OperationList)
      ops.protocol = @protocol
      ops
    end

    def running
      result = select { |op| 
        op.status != "error"
      }
      result
    end    

    def errored
      select { |op| op.status == "error" }
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
          input.retrieve unless input.child_item
          if input.child_item_id
              op_items << input.child_item
          else
              op.set_status "error"
              sname = input.child_sample ? input.child_sample.name : '-'
              oname = input.child_item ? input.child_item.object_type.name : '-'
              op.associate "input error", "Could not find input #{input.name}: #{sname} / #{oname}"
          end                         
        end
        items = items + op_items unless op.status == "error"
      end

      if block_given?
        @protocol.take items.uniq, opts, &Proc.new
      else
        @protocol.take items.uniq, opts        
      end

      self

    end

    def output_collections
      @output_collections ||= {}
      @output_collections
    end

    def make opts={errored:false,role:'output'}

      puts "====== make: ROLE: #{opts[:role]}"

      @output_collections = {}
      ops = select { |op| opts[:errored] || op.status != "error" }

      ops.each_with_index do |op,i|
        puts "====== make: operation #{op.id}"
        op.field_values.select { |fv| fv.role == opts[:role] }.each do |fv| 
          puts "======= making #{fv.name}"
          if fv.part?

            rows = fv.object_type.rows
            columns = fv.object_type.columns
            size = rows * columns

            unless @output_collections[fv.name]
              @output_collections[fv.name] = (1..ops.length/+1).collect do |c|
                fv.make_collection 
              end
            end

            fv.make_part(@output_collections[fv.name][i/size],(i%size)/columns,(i%size)%columns)

          elsif fv.object_type && fv.object_type.handler == "collection"
            fv.make_collection 1, 10
          else
            fv.make
          end         
        end
      end

      self

    end

    def store opts={interactive:true,method: "boxes",errored:false,io:"all"}

      items = []

      select { |op| opts[:errored] || op.status != "error" }.each_with_index do |op,i|         
        op.field_values.select { |fv| opts[:io] == "all" || fv.role == opts[:io] }.each do |input|
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

            t.set(fv.name,               fv.child_sample ? fv.child_sample.name : "NO SAMPLE")          
             .set(collection_column(fv), fv.child_item_id ? fv.child_item_id : "NO COLLECTION")
             .set(row_column(fv),        fv.row)
             .set(column_column(fv),     fv.column)                          

          else

            t.column(fv.name,         fv.name)
             .column(item_column(fv), item_column(fv)) unless t.has_column? fv.name

            t.set(fv.name,         fv.child_sample ? fv.child_sample.name : "NO SAMPLE")          
             .set(item_column(fv), fv.child_item_id ? fv.child_item_id : "NO ITEM")

          end
                     
        end
        
        t.append

      end

      t

    end

  end
  
end