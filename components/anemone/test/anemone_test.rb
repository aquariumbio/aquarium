# frozen_string_literal: true

# typed: false

require 'test_helper'

class Anemone::Test < ActiveSupport::TestCase
  test 'truth' do
    assert_kind_of Module, Anemone
  end
end
