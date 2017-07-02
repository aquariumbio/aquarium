class CreateJobAssociations < ActiveRecord::Migration
  def change
   create_table :job_associations do |t|
      t.references :job
      t.references :operation
      t.timestamps      
    end    
  end
end
