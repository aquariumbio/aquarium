

require 'rails_helper'

RSpec.describe TimeSpec do

  context 'basic' do

    it 'parses examples' do
      (TimeSpec.new 'now').parse
      (TimeSpec.new 'immediately').parse
      (TimeSpec.new '12:00 after previous').parse
      (TimeSpec.new 'day 2 at 12:34').parse
      (TimeSpec.new '12:23:34 from now').parse
      (TimeSpec.new 'today at 15:00').parse
    end

  end

end
