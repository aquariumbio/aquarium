# frozen_string_literal: true

require './plankton'

p = Plankton::Parser.new File.read ARGV.shift

puts p.expr
