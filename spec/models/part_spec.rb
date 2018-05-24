require "rails_helper"

RSpec.describe Part, :type => :model do

  context "initialization and accessors" do

    col = (Collection.every.reject { |c| c.deleted? }).last.becomes Collection
    s = Sample.find(col.matrix[0][0])

    it "initializes" do
      part = Part.new col, 0, 0
    end

    it "does not initialize if x or y is out of range" do
      (expect { Part.new col, 12, 23 }).to raise_error "out of range"
    end

    it "responds to sample" do
      part = Part.new col, 0, 0
      expect(part.sample).to eq(s)
    end

    it "responds to object type" do
      part = Part.new col, 0, 0
      expect(part.object_type).to eq(col.object_type)
    end

  end

end
