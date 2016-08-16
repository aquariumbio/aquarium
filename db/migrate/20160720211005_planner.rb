class Planner < ActiveRecord::Migration

  def change

    create_table :operation_types do |t|
      t.string :name
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
    add_column :field_types, :part, :boolean

    add_column :field_values, :role, :string    
    add_column :field_values, :field_type_id, :integer
    add_column :field_values, :row, :integer
    add_column :field_values, :column, :integer

    add_index :field_values, :field_type_id

    create_table :wires do |t|
      t.integer :from_id
      t.integer :to_id
      t.boolean :active
      t.timestamps      
    end

    create_table :plans do |t|
      t.references :user
      t.timestamps      
    end

    add_index :plans, :user_id

    create_table :plan_associations do |t|
      t.references :plan
      t.references :operation
      t.timestamps      
    end

    add_index :plan_associations, :plan_id
    add_index :plan_associations, :operation_id

    create_table :codes do |t|
      t.string :name
      t.text :content
      t.integer :parent_id
      t.string :parent_class
      t.integer :child_id
      t.timestamps
    end

  end

end
