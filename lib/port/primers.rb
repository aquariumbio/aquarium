# frozen_string_literal: true

require 'csv'
require 'port/user'

def import_primers
  CSV.foreach('/var/rails/btor_test/lib/port/primers.csv', 'r') do |row|
    p = Primer.new
    p.id          = row[0].to_i
    p.description = row[1]
    p.annealing   = row[2]
    p.overhang    = row[3]
    p.created_at  = Date.parse(row[4])
    p.updated_at  = Date.parse(row[5])
    p.tm          = row[6].to_f
    p.notes       = row[7]
    p.project     = row[8].to_i
    p.owner       = new_user_id(row[9].to_i)
    p.save
  end
end
