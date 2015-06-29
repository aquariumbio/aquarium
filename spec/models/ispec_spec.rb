require "rails_helper"

RSpec.describe Ispec, :type => :model do

  context "initialization" do

    it "initializes from attributes" do
      is = Ispec.new name: "whatever"
      expect(is.name).to eq("whatever")
    end

    it "ignores unknown attributes" do
      is = Ispec.new nome: "whatever"
    end

  end

  context "satisfied by an item" do

    st = SampleType.find_by_name("Primer")
    s = st.samples[100]
    i = s.items.last

    it "is satisfied by an item when it specifies a single item" do
      is = Ispec.new item: i.id
      expect(is.satisfied_by? i).to eq(true)
    end

    it "is satisfied by an item when it specifies a list of items" do
      is = Ispec.new item: [i.id,2]
      expect(is.satisfied_by? i).to eq(true)
    end    

    it "is not satisfied by an item when it specifies a disjoint list of items" do
      is = Ispec.new item: [1,2]
      expect(is.satisfied_by? i).to eq(false)
    end

    it "is satisfied by an item when it specifies a container type" do
      is = Ispec.new container: i.object_type.id
      expect(is.satisfied_by? i).to eq(true)
    end

    it "is satisfied by an item when it specifies a sample" do
      is = Ispec.new sample: s.id
      expect(is.satisfied_by? i).to eq(true)
    end

    it "is satisfied by an item when it specifies a sample type" do
      is = Ispec.new sample_type: st.id
      expect(is.satisfied_by? i).to eq(true)
    end    

  end

  context "satisfied_by a matrix" do

    st = SampleType.find_by_name("Primer")
    s = st.samples[100]
    i = s.items.last

    it "is satisfied by a matrix of items" do
      is = Ispec.new dimension: [1,1], sample: s.id
      expect(is.satisfied_by? [[i]]).to eq(true)
    end    

  end

  context "satisfied by a part of a collection" do

    col = (Collection.every.reject { |c| c.deleted? }).last.becomes Collection
    part = Part.new col, 0, 0
    s = part.sample

    it "is satisfied by a part" do
      is = Ispec.new is_part: true
      expect(is.satisfied_by? part).to eq(true)
    end

    it "is satisfied by a part when an object type is specified" do
      is = Ispec.new is_part: true, container: col.object_type.id
      expect(is.satisfied_by? part).to eq(true)
    end

    it "is satisfied by a part when an object type and a sample are specified" do
      is = Ispec.new is_part: true, container: col.object_type.id, sample: s.id
      expect(is.satisfied_by? part).to eq(true)
    end     

    it "is satisfied by a part when a specific collection is specified" do
      is = Ispec.new is_part: true, item: col.id
      expect(is.satisfied_by? part).to eq(true)
    end        

    it "is satisfied by a part when a specific collection and row and column are specified" do
      is = Ispec.new is_part: true, item: col.id, row: 0, col: 0
      expect(is.satisfied_by? part).to eq(true)
    end  

    it "is not satisfied by a part when a specific collection and row and column are incorrectly specified" do
      is = Ispec.new is_part: true, item: col.id, row: 0, col: 1
      expect(is.satisfied_by? part).to eq(true)
    end            

  end

end
