require 'rails_helper'

RSpec.describe FieldTyper do 
  let(:mock_owner_class) { build_mock_typer_class }
  let!(:ex_object_type) { create(:object_type) }
  let!(:ex2_object_type) { create(:object_type) }
  let!(:ex_sample_type) { create(:sample_type) }
  let!(:ex2_sample_type) { create(:sample_type) }

  before(:all) { create_typer_table }
  after(:all) { drop_typer_table }

  before(:each) do
    @owner = mock_owner_class.new
    @owner.save
  end

  it 'has no fields if not added' do
    expect(@owner.field_types).to be_empty
    expect(@owner.type('the type')).to be_nil
  end

  it 'has fields if added' do
    object = @owner.add_field('the type', 'sample_type', 'object_type', 'input', {})
    expect(object).to eq(@owner)
    expect(@owner.field_types).not_to be_empty
    expect(@owner.type('the type')).not_to be_nil
  end

  it 'cannot add field with same name' do
    @owner.add_field('the type', 'sample_type', 'object_type', 'input', {})
    @owner.add_field('the type', 'sample_type', 'object_type', 'input', {})
    expect(@owner.type('the type')).not_to be_nil

    skip('FieldType does not currently enforce uniqueness')
    expect(@owner.field_types.length).to eq(1)
  end

  it 'creating field with nonexistent sample and object type creates null allowable field types' do
    @owner.add_field('the type', 'sample_type', 'object_type', 'input', {})
    field_type = @owner.type('the type')
    expect(field_type.allowable_field_types.length).to eq(1)
    type = field_type.allowable_field_types.first
    expect(type).not_to be_nil
    expect(type.sample_type).to be_nil
    expect(type.object_type).to be_nil
  end

  it 'can add fields using array or string' do
    @owner.add_field('type_1', ex_sample_type.name, ex_object_type.name, 'input', {}) 
    @owner.add_field('type_2', [ex_sample_type.name], ex_object_type.name, 'input', {}) 
    @owner.add_field('type_3', [ex_sample_type.name], [ex_object_type.name], 'input', {})
    expect(@owner.field_types.length).to eq(3)
    aft_type1 = @owner.type('type_1').allowable_field_types.first
    aft_type2 = @owner.type('type_2').allowable_field_types.first
    aft_type3 = @owner.type('type_3').allowable_field_types.first
    expect(aft_type1.sample_type).to eq(ex_sample_type)
    expect(aft_type2.object_type).to eq(ex_object_type)
    expect(aft_type1.sample_type).to eq(aft_type2.sample_type)
    expect(aft_type2.sample_type).to eq(aft_type3.sample_type)
    expect(aft_type1.object_type).to eq(aft_type2.object_type)
    expect(aft_type2.object_type).to eq(aft_type3.object_type)
  end

  it 'field type export to serialize AFTs as parallel arrays' do
    expect(ex_sample_type).not_to eq(ex2_sample_type)
    expect(ex_object_type).not_to eq(ex2_object_type)
    @owner.add_field(
      'multiple_types',
      [ex_sample_type.name, ex2_sample_type.name],
      [ex_object_type.name, ex2_object_type.name],
      'input',
      {}
    )
    expect(@owner.field_types.length).to eq(1)
    field_type_export = @owner.export_field_types
    expect(field_type_export).not_to be_nil
    expect(field_type_export.length).to eq(1)
    type_hash = field_type_export.first
    expect(type_hash[:sample_types]).to eq([ex_sample_type.name, ex2_sample_type.name])
    expect(type_hash[:object_types]).to eq([ex_object_type.name, ex2_object_type.name])
  end

  it 'save_field_types should add or delete field types as indicated by hash'

end

def build_mock_typer_class
  Class.new(ActiveRecord::Base) do
    self.table_name = 'mock_owner_table'
    include FieldTyper
  end
end

def create_typer_table
  ActiveRecord::Base.connection.create_table :mock_owner_table do |t|
  end
end

def drop_typer_table
  ActiveRecord::Base.connection.drop_table :mock_owner_table
end