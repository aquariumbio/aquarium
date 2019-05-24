# frozen_string_literal: true

class AddFieldsAndDescriptionToSamples < ActiveRecord::Migration

  def change

    # Description
    add_column :samples, :description, :string

    # Two new generic fields
    add_column :sample_types, :field7name, :string
    add_column :sample_types, :field7type, :string
    add_column :samples, :field7, :string

    add_column :sample_types, :field8name, :string
    add_column :sample_types, :field8type, :string
    add_column :samples, :field8, :string

  end

end
