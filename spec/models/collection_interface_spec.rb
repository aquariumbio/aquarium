require 'rails_helper'

RSpec.describe Collection, type: :model do

  # Tests new_collection
  def example_collection
    c = Collection.new_collection("Stripwell")
    c.save
    raise "Got save errors: #{c.errors.full_messages}" if c.errors.any?
    c
  end  

  context 'construction' do

    # tests new_collection
    #         => apportion
    #       matrix
    it 'can make new collections' do
      c = example_collection
      raise "Wrong size" unless c.matrix.length == 12 && c.matrix[0].length == 1
    end

    # tests new_collection
    #       matrix
    #       set     
    it 'can set parts' do
      c = example_collection
      c.set 5,0,Sample.last
      raise "Did not set part" unless c.matrix[5][0] == Sample.last.id
      raise "string view incorrect" unless c.non_empty_string == "1,1 - 6, 1"            
    end

  end

  context 'finding' do

    # tests containing
    #       position, position_as_hash
    #         => find
    #           => to_sample_id
    it 'finds collections containing a specific sample' do
      Collection.containing(Sample.find(4926)).each do |item|
        collection = Collection.find(item.id) # TODO: Make it so that you don't have to do this
        raise "Sample should be in collection" unless collection.position(4926) && collection.position_as_hash(4926)
      end
    end    

    # tests parts
    #         => position_as_hash
    #         => find
    #           => to_sample_id    
    it 'finds parts and their containing collections with a specific sample' do
      Collection.parts(Sample.find(4926)).each do |part|
        collection = Collection.find(part[:collection].id) # TODO: Make it so that you don't have to do this
        pos = collection.position_as_hash(4926)
        raise "Sample should be in collection in specified slot" unless pos[:row] == part[:row] && pos[:column] = part[:column]
      end
    end        

  end

  context 'setting and getting' do

    # tests new_collection
    #       set     
    #       get_non_empty
    #       get_empty
    #       num_samples
    #       capacity
    #         dimensions
    #       include?
    it 'can set slots to samples' do
      c = example_collection
      c.set 5,0,Sample.last  
      c.set 8,0,Sample.first
      raise "Slots not adding up" unless c.get_empty.length + c.get_non_empty.length == c.capacity
      raise "Non-empty not adding up" unless c.get_non_empty.length == c.num_samples
      raise "include? not working" unless c.include?(Sample.last) && c.include?(Sample.last.id)
      raise "select not working" unless c.select { |x| x == Sample.last.id }.length == 1
    end

    # test set_matrix
    #        => associate
    #      matrix
    it 'sets a matrix of samples' do
      c = example_collection
      samples = Sample.all.sample(12).collect { |s| [ s ] }
      c.set_matrix samples
      (0..11).each do |i|
        c.matrix[i][0] == samples[i][0].id
      end
    end

    # test matrix=
    #      matrix
    it 'sets a matrix of sample ids' do
      c = example_collection
      samples = Sample.all.sample(12).collect { |s| [ s.id ] }
      c.matrix = samples
      (0..11).each do |i|
        raise "Setting matrix didn't work" unless c.matrix[i][0] == samples[i][0]
      end
    end    

    # tests spread
    #         => add_samples
    #       matrix
    it 'can sporead a bunch of samples accross multiple collections' do
      samples = Sample.all.sample(17)
      collections = Collection.spread(samples, "Stripwell")
      sids1 = samples.map(&:id)
      sids2 = collections.map(&:matrix).flatten.reject { |sid| sid <= 0 }
      raise "Example sample ids not found" unless sids1 == sids2
      raise "full? returned unexpected value" unless collections[0].full? && !collections[1].full?
    end

    # test set_matrix
    #        => associate
    #      matrix
    it 'sets a matrix of samples' do
      c = example_collection
      c.set 5,0,Sample.last        
      samples = Sample.all.sample(12).collect { |s| [ s ] }
      c.add_one(Sample.all.sample)
      c.add_one(Sample.all.sample)  
      c.subtract_one 
      raise "add_one and subtract_one not adding up" unless c.get_non_empty.length == 2
    end

    # test next
    it 'sets a matrix of sample ids' do
      c = example_collection
      samples = (1..2).collect { |i| Sample.all.sample(3).map(&:id) }
      c.matrix = samples
      p = [0,0]
      (0..1).each do |i|
        (0..2).each do |j|
          raise "Next didn't align" unless p == [i,j]
          p = c.next(p[0],p[1])          
        end
      end
      c.set 1, 1, -1
      raise "skip_non_empty option not working" unless c.next(0,0,skip_non_empty: true) == [1,1]
      raise "edge condition didn't work" unless c.next(1,2) == [nil,nil]
    end       

  end

end
