# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CodeHelper do
  let(:mock_owner_class) { build_mock_code_class }
  let!(:a_user) { create(:user) }

  before(:all) { create_code_table }
  after(:all) { drop_code_table }

  before(:each) do
    @owner = mock_owner_class.new
    @owner.save
  end

  it 'has no code if not added' do
    expect(@owner.code).to be_nil
    expect(@owner.code('the_code')).to be_nil
  end

  it 'has code if added' do
    code_object = @owner.new_code('the_code', 'def noop; end', a_user)
    expect(code_object).not_to be_nil
    expect(@owner.code('the_code')).not_to be_nil
  end

  it 'cannot add code with same name' do
    @owner.new_code('the_code', 'def noop; end', a_user)
    expect { @owner.new_code('the_code', 'def noop; end', a_user) }.to raise_error
  end

  it 'attributes of created object are as expected' do
    code_object = @owner.new_code('the_code', 'def noop; end', a_user)
    expect(code_object.name).to eq('the_code')
    expect(code_object.content).to eq('def noop; end')
    expect(code_object.parent_class).to eq(mock_owner_class.to_s)
    expect(code_object.user_id).to eq(a_user.id)
  end
end

def build_mock_code_class
  Class.new(ActiveRecord::Base) do
    self.table_name = 'mock_owner_table'
    include CodeHelper
  end
end

def create_code_table
  ActiveRecord::Base.connection.create_table :mock_owner_table do |t|
  end
end

def drop_code_table
  ActiveRecord::Base.connection.drop_table :mock_owner_table
end
