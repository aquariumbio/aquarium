# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group do
  let!(:dummy_group) { create(:group, name: 'dummy_group', description: 'a group for this test') }
  let!(:dummy_user) { create(:user) }

  it 'group names should include defaults plus dummy user and group' do
    names = Group.list_names
    expect(names[:groups]).to match_array(['admin', 'dummy_group', 'technicians'])
    expect(names[:users]).to match_array([dummy_user.login, 'neptune'])
  end

  it 'dummy user should not be member of dummy_group until added' do
    expect(dummy_group).not_to be_member(dummy_user)

    dummy_group.add(dummy_user)
    expect(dummy_group).to be_member(dummy_user)
  end

  it 'nonuser groups are admin, retired and technicians and dummy_group' do
    expect(Group.non_user_groups).to match_array([Group.admin, Group.retired, Group.technicians, dummy_group])
  end

end
