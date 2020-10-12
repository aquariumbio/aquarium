require 'test_helper'

class DevOnlyTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, DevOnly
  end
end
