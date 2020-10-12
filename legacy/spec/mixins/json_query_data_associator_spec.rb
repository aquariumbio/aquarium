# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonController::JsonQueryResult do
  # This tests accessing data associations through the JSON controller

  # Use a mock class rather than an Aquarium model
  let(:mock_owner_class) { build_mock_associator_class }

  before(:all) { create_associator_table }
  after(:all) { drop_associator_table }

  before(:each) do
    @owner = mock_owner_class.new
    @owner.save

    @owner.associate('key1', 'value1', nil, { duplicates: true })
    @owner.associate('key2', 'value2', nil, { duplicates: true })
    @owner.associate('key1', 'value3', nil, { duplicates: true })
    @owner.associate('key1', 'value4', nil, { duplicates: true })
    @owner.save
  end

  it 'expect JsonQueryResult to work with mock class' do
    expect { JsonController::JsonQueryResult.create_from(model: mock_owner_class.name) }.not_to raise_error(NameError)
    expect { JsonController::JsonQueryResult.create_from(model: mock_owner_class.name) }.to raise_error('Query method expected')
    owners = JsonController::JsonQueryResult.create_from(model: mock_owner_class.name, method: 'all')
    expect(owners).not_to be_empty
  end

  it 'data association query should return most recently updated values' do
    params = ActionController::Parameters.new(
      {
        'model' => 'DataAssociation',
        'method' => 'where',
        'arguments' => {
          'parent_id' => @owner.id,
          'parent_class' => [mock_owner_class.name]
        },
        'options' => {
          'offset' => -1,
          'limit' => -1,
          'reverse' => true
        },
        'json' => { 'model' => 'DataAssociation', 'method' => 'where', 'arguments' => { 'parent_id' => @owner.id, 'parent_class' => [mock_owner_class.name] }, 'options' => { 'offset' => -1, 'limit' => -1, 'reverse' => false } }
      }
    )
    results = JsonController::JsonQueryResult.create_from(params)
    expect(results).not_to be_empty
    expect(results.length).to eq(2)

    expect(results.first['key']).to eq('key1')
    expect(JSON.parse(results.first['object'])).to eq({ 'key1' => 'value4' })
    expect(results.last['key']).to eq('key2')
    expect(JSON.parse(results.last['object'])).to eq({ 'key2' => 'value2' })
  end

end

def build_mock_associator_class
  # TODO: don't recreate if this class has already been created
  Object.const_set('MockOwnerClass',
                   Class.new(ActiveRecord::Base) do
                     self.table_name = 'mock_owner_table'
                     include DataAssociator
                   end)
end

def create_associator_table
  ActiveRecord::Base.connection.create_table :mock_owner_table do |t|
  end
end

def drop_associator_table
  ActiveRecord::Base.connection.drop_table :mock_owner_table
end
