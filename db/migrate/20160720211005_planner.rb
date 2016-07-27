class Planner < ActiveRecord::Migration

  def change

    create_table :operation_types do |t|
      t.string :name
      t.string :protocol
      t.timestamps      
    end

    create_table :operations do |t|
      t.references :operation_type
      t.string :status
      t.references :user
      t.references :job
      t.timestamps
    end

    add_index :operations, :operation_type_id
    add_index :operations, :user_id
    add_index :operations, :job_id

    add_column :field_types, :role, :string
    add_column :field_values, :role, :string    

    add_column :field_values, :field_type_id, :integer
    add_index :field_values, :field_type_id

    create_table :wires do |t|
      t.integer :from_id
      t.integer :to_id
    end

  end

end
