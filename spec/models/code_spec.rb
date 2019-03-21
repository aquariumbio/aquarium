require 'rails_helper'

RSpec.describe CodeHelper do
  let(:code) { create(:code) }
  let(:a_user) { create(:user) }
  
  it 'example object has values from factory' do
    expect(code.name).to eq('the_code')
    expect(code.content).to eq('def the_code; end')
    expect(code.parent_class).to eq('DummyClass')
  end

  it 'code should update after commit' do
    expect(code.content).to eq('def the_code; end')
    new_code = code.commit('def updated_code; end', a_user)
    expect(new_code.content).to eq('def updated_code; end')
  end

  it 'versions should include all committed versions' do
    expect(code.content).to eq('def the_code; end')
    code2 = code.commit('def updated_code2; end', a_user)
    code3 = code2.commit('def updated_code3; end', a_user)
    expect(code.versions).to include(code, code2, code3)
    expect(code2.versions).to include(code, code2, code3)
  end
end