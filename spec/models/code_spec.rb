require 'rails_helper'

RSpec.describe CodeHelper do
  let(:code) { create(:code) }
  let(:markdown) { create(:code, content: '# A document\n\nNot ruby code.') }
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

  # TODO: really want this to behave badly
  it 'loading markdown as krill returns nil' do
    expect(markdown.load).to be_nil
  end

  it 'loading code with syntax error should raise exception' do
    bad_content = "def bad_code" \
                  "  1=2" \
                  "end"
    bad_code = create(:code, content: bad_content)
    expect { bad_code.load }.to raise_error(SyntaxError)
  end

  it 'loading code with precondition should return function name as symbol' do
    code_content = "def precondition(operation) true end"
    pre_code = create(:code, content: code_content)
    expect(pre_code.load).to eq(:precondition)
  end

  it 'loading simple protocol returns main' do
    protocol = "class Protocol\n  def main\n      true\n    end\n  end"
    code_object = create(:code, content: protocol)
    expect(code_object.load).to eq(:main)
  end

  it 'loading protocol returns last method' do
    protocol = "class Protocol\n  def main\n      true\n    end\n  def sub\n      true\n    end\n  end"
    code_object = create(:code, content: protocol)
    expect(code_object.load).to eq(:sub)
  end
end
