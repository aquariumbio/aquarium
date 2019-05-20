class CreateSampleTypes < ActiveRecord::Migration
  def change
    create_table :sample_types do |t|
      t.string :name
      t.string :description
      t.string :field1name
      t.string :field1type
      t.string :field2name
      t.string :field2type
      t.string :field3name
      t.string :field3type
      t.string :field4name
      t.string :field4type

      t.timestamps
    end
  end
end
