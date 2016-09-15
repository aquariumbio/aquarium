# This is a default, one-size-fits all protocol that shows how you can 
# access the inputs and outputs of the operations associated with a job.
# Add specific instructions for this protocol!

class Protocol

  def main

    output_collections = {}
    input_table = Table.new
    output_table = Table.new

    operations.each_with_index do |op,i|
        
      op.inputs.each do |input|
          
        input.retrieve
        
        if !input.child_item_id
            op.set_status "error"
            op.associate "input error", "Could not find input #{input.child_sample.name}"
        end
        
        input_table.column(input.name,input.name) 
                   .column(input.name+"-item","id") unless input_table.has_column? input.name
                   
        input_table.set(input.name,input.child_sample.name)
                   .set(input.name+"-item",input.child_item_id ? input.child_item_id : "?")
                   
      end
      
      input_table.append

      unless op.status == "error"

        op.outputs.each do |output|

          if output.part?
            output_collections[output.name] ||= output.make_collection(operations.count, 1)
            output.make_part(output_collections[output.name],i,0)
          else
            output.make
          end
          
          output_table.column(output.name,output.name)
                      .column(output.name+"-item","id") unless output_table.has_column? output.name

          output_table.set(output.name,output.child_sample.name)          
          output_table.set(output.name+"-item","#{output.child_item_id}") unless output.part?
          output_table.set(output.name+"-item","#{output.child_item_id}(#{output.row},#{output.column})") if output.part?
                                
        end
      
        output_table.append
        
      end

    end

    show do
      title "Inputs"
      table input_table.all.render
    end
    
    show do
      title "Outputs"
      table output_table.all.render
    end    
    
    error_ops = operations.select { |op| op.status == "error" }
    
    show do
      title "Errors"
      error_ops.each do |op|
          note "#{op.id}: #{op.get('input error')}"
      end
      note "None" if error_ops.empty?
    end

    return {}  

  end

end
