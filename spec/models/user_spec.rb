# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'create_user_group should add group with user login' do
    login_name = 'joe1'
    expect(Group.find_by(name: login_name)).to be_nil
    user = User.new(name: 'Joe', login: login_name, password: 'blah', password_confirmation: 'blah')
    expect(user.login).to eq(login_name)
    group = user.create_user_group
    expect(Group.find_by(name: login_name)).to eq(group)

    expect{user.create_user_group}.to raise_error(ActiveRecord::RecordInvalid)
  end

  let!(:user){create(:user)}
  it 'make_admin should make user admin' do
    expect(user.is_admin).to be false
    user.make_admin
    expect(user.is_admin).to be true
  end
end