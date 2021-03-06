# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Krill::ShowBlock do
  let!(:empty_block) { Krill::ShowBlock.new(Krill::Base) }

  it 'an integer is not a proper array' do
    expect(Krill::ShowBlock.is_proper_array(1)).to be false
  end

  it 'an empty array is proper' do
    expect(Krill::ShowBlock.is_proper_array([])).to be true
  end

  it 'an array with a unexpected element is not proper' do
    expect(Krill::ShowBlock.is_proper_array([empty_block])).to be false
  end

  it 'an array of integers is proper' do
    expect(Krill::ShowBlock.is_proper_array([1])).to be true
    expect(Krill::ShowBlock.is_proper_array([1, 2])).to be true
    expect(Krill::ShowBlock.is_proper_array([1, 2, 3])).to be true
  end

  it 'an array with different types is not proper' do
    expect(Krill::ShowBlock.is_proper_array([1, 1.0])).to be false
  end

  it 'cannot call show within show' do
    expect { empty_block.show }.to raise_error(RuntimeError, "Cannot call 'show' within a show block.")
  end

  it 'A show block has a title after title has been called' do
    block = Krill::ShowBlock.new(Krill::Base)
    page_title = 'Page Title'
    block.title(page_title)
    page_parts = block.run {}

    expect(page_parts).to include({ title: page_title })
  end

  it 'A show block has a note after note has been called' do
    block = Krill::ShowBlock.new(Krill::Base)
    note_text = 'The dough should spring back when you press it'
    block.note(note_text)
    page_parts = block.run {}

    expect(page_parts).to include({ note: note_text })
  end

  it 'Notes should be in the same order as inserted' do
    block = Krill::ShowBlock.new(Krill::Base)
    note_array = %w[Text1 Text2]
    note_array.each { |note| block.note(note) }
    page_parts = block.run {}

    # shouldn't have objects that weren't inserted
    expect(page_parts.length).to eq(2)

    # TODO: want to check order, but don't want to assume we have an array
    expect(page_parts[0]).to eq({ note: note_array[0] })
    expect(page_parts[1]).to eq({ note: note_array[1] })
  end

  it 'Inserting note array should give same result as consecutive note calls' do
    block1 = Krill::ShowBlock.new(Krill::Base)
    note_array = %w[Text1 Text2]
    note_array.each { |note| block1.note(note) }
    page_parts1 = block1.run {}

    block2 = Krill::ShowBlock.new(Krill::Base)
    block2.note(note_array)
    page_parts2 = block2.run {}

    expect(page_parts1).to eq(page_parts2)
  end

  it 'Injecting show block should give the same result as consecutive calls' do
    block1 = Krill::ShowBlock.new(Krill::Base)
    note_array = %w[text1 text2 text3]
    note_array.each { |note| block1.note(note) }
    expected_parts = block1.run {}

    sub_block = Krill::ShowBlock.new(Krill::Base)
    sub_block.note('text2')

    block2 = Krill::ShowBlock.new(Krill::Base)
    block2.note('text1')
    block2.insert(sub_block)
    block2.note('text3')
    computed_parts = block2.run {}

    expect(computed_parts).to eq(expected_parts)
  end

  it 'A show block has a warning after warning has been called'
  it 'Order of warnings should be maintained'
  it 'A show block has a check after check has been called'
  it 'Order of checks should be maintained'
  it 'Inserting array of checks is the same as consecutive check calls'
  it 'A show block has a bullet after bullet has been called'
  it 'Order of bullets should be maintained'
  it 'Inserting array of bullets is the same as consecutive bullet calls'
  it 'A show block has a table after table has been called'
  it 'A show block has a take for an item after item has been called'
  it 'A show block has a separator after separator has been called'
  it 'A show block has an image after image has been called'
  it 'A show block has a timer after timer has been called'
  it 'A show block has an upload after upload has been called'
  it 'A show block has an input after get has been called'
  it 'A show block has a select after select has been called'

end
