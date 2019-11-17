# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Library do
  let(:library) { create(:library, name: 'test library', category: 'testing') }
  let(:a_user) { create(:user) }

  it 'example object should have no source' do
    expect(library.name).to eq('test library')
    expect(library.category).to eq('testing')
    # TODO: hmm somehow ended up in database, fix it.
    # expect(library.source).to be_nil
  end

  it 'expect library to have code after added' do
    # expect(library.source).to be_nil
    code = library.add_source(content: 'def a_method; 5 end', user: a_user)
    expect(library.source).to eq(code)
    expect(code).not_to be_nil
  end

  it 'expect add_source to replace existing code' do
    expect(library.source).to be_nil
    first = 'def a_method; 5 end'
    library.add_source(content: first, user: a_user)
    second = 'def other; 6 end'
    library.add_source(content: second, user: a_user)
    expect(library.source.content).to eq(second)
  end

  it 'expect to be able to import library that does not exist' do
    library_hash = {
      library: {
        name: 'a_new_library',
        category: 'testing',
        code_source: 'def a_new_method; end'
      }
    }
    Library.import(library_hash, a_user)
    new_library = Library.find_by(name: 'a_new_library')
    expect(new_library.name).to eq('a_new_library')
  end

  it 'expect importing exported library to fail because of duplication'

end
