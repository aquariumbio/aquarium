# frozen_string_literal: true

require './lib/pdl'

p = ProduceInstruction.new '1000 mL Bottle', 'B1.465'

p.execute
