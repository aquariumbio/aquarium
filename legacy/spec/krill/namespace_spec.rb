# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Krill::Namespace do
  let(:basic_library) do
    create(
      :library,
      name: 'test library',
      category: 'testing',
      source: 'def a_method; 5 end',
      user: test_user
    )
  end
  let(:test_user) { create(:user) }
  let(:simple_code) do
    create(
      :code,
      name: 'empty protocol',
      content: 'class Protocol; def main; end end'
    )
  end
  let(:show_code) do
    create(
      :code,
      name: 'simple show',
      content: 'class Protocol; def main; show { title \'blah\'} end end'
    )
  end

  it 'expect basic library to have code' do
    # just a sanity check on factory
    expect(basic_library.source).not_to be_nil
  end

  it 'expect namespace to have protocol' do
    namespace = Krill.make_namespace(code: simple_code)
    expect(namespace).not_to be_nil
    expect(namespace::Protocol).not_to be_nil
    expect(namespace).to respond_to(:needs)
  end

  it 'expect unspecified namespace to not have protocol' do
    namespace = Krill.make_namespace
    expect(namespace).not_to be_nil
    expect(namespace).to respond_to(:needs)
    expect { namespace::Protocol }.to raise_error(NameError)
    namespace.add(code: simple_code)
    expect(namespace::Protocol).not_to be_nil
    expect(namespace::Protocol.instance_methods).to include(:main)
  end

  it 'expect code with calls to undefined methods not to behave badly' do
    namespace = Krill.make_namespace
    namespace.add(code: show_code)
    expect(namespace::Protocol).not_to be_nil
    expect(namespace::Protocol.instance_methods).to include(:main)
  end

end
