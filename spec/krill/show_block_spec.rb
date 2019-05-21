# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Krill::ShowBlock do
  block = Krill::ShowBlock.new(Krill::Base)

  it 'an integer is not a proper array' do
    expect(block.is_proper_array(1)).to be false
  end

  it 'an empty array is not proper' do
    expect(block.is_proper_array([])).to be false
  end

  it 'an array with a unexpected element is not proper' do
    expect(block.is_proper_array([block])).to be false
  end

  it 'an array of integers is proper' do
    expect(block.is_proper_array([1])).to be true
    expect(block.is_proper_array([1, 2])).to be true
    expect(block.is_proper_array([1, 2, 3])).to be true
  end

  it 'an array with different types is not proper' do
    expect(block.is_proper_array([1, 1.0])).to be false
  end

  it 'cannot call show within show' do
    expect { block.show }.to raise_error(RuntimeError, "Cannot call 'show' within a show block.")
  end
end