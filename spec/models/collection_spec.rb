require 'rails_helper'

RSpec.describe Collection, type: :model do

  context 'slot iteration' do

    it 'can iterate over and remember slots' do

      ca = Krill::CollectionArray.new

      2.times do
        ca << (Collection.new_collection 'Stripwell', 1, 12)
      end

      puts 'looping over 2 collections'
      ca.slots do |index, slot|
        slot.ingredients[:stuff] = Math.sqrt(index.to_f)
        slot.sample = Sample.last
        puts "#{index}: #{slot.collection.id}, #{slot.row}, #{slot.col}, #{slot.sample}"
      end

      ca << (Collection.new_collection 'Stripwell', 1, 12)

      ca.slot(2, 0, 3).sample = Sample.last

      puts 'added another collection, and a sample to one slot, and looping over non-empty slots'
      ca.slots do |index, slot|
        puts "#{index}: #{slot.collection.id}, #{slot.row}, #{slot.col}, #{slot.ingredients}" unless slot.empty?
      end

      puts 'looping over only the third collection'
      ca.slots 2 do |index, slot|
        puts "#{index}: #{slot.collection.id}"
      end

    end

  end

  context 'collection tables' do

    it 'can make nice tables' do

      primer_stocks = ObjectType.find_by_name('Primer Stock').items
      frags = SampleType.find_by_name('Fragment').samples

      ca = Krill::CollectionArray.new

      2.times do
        ca << (Collection.new_collection 'Stripwell', 2, 6)
      end

      ca.slots do |index, slot|
        slot.sample = frags[rand(frags.length)]
        ps = primer_stocks[rand(primer_stocks.length)]
        slot.ingredients[:primer_stock] = { id: ps.id, vol: Math.sqrt(index).round(2) }
      end

      ca.table(0, id: 'Stripwell', row: 'Row', col: 'Column', primer_stock: 'Primer Stock').each do |r|
        puts r.join("\t")
      end

      ca.table(1, primer_stock: 'Primer Stock').each do |r|
        puts r.join("\t")
      end

    end

  end

end
