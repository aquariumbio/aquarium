# This is a default, one-size-fits all protocol that shows how you can 
# access the inputs and outputs of the operations associated with a job.
# Add specific instructions for this protocol!

needs "Standard Libs/Debug"

class Protocol

  include Debug

  def main

    operations.retrieve.make
    
    tin  = operations.io_table "input"
    tout = operations.io_table "output"
    
    show do 
      title "Input Table"
      table tin.all.render
    end
    
    show do 
      title "Output Table"
      table tout.all.render
    end
    
    operations.store
    
    return {}
    
  end

end
