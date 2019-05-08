require 'rails_helper'

Rspec.describe FieldTyper do 
  let(:mock_owner_class) { build_mock_class }

  before(:all) { create_table }
  after(:all) { drop_table }

  before(:each) do
    @owner = mock_owner_class.new
    @owner.save
  end

  
end

def build_mock_class
  Class.new(ActiveRecord::Base) do
    self.table_name = 'mock_owner_table'
    include FieldTyper
  end
end

def create_table
  ActiveRecord::Base.connection.create_table :mock_owner_table do |t|
  end
end

def drop_table
  ActiveRecord::Base.connection.drop_table :mock_owner_table
end