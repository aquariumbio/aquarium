class Sample < ActiveRecord::Base

  attr_accessible :field1, :field2, :field3, :field4, :field5, :field7, :field6, :field8, :name, :user_id, :project, :sample_type_id, :user_id, :description
  belongs_to :sample_type
  belongs_to :user
  has_many :items

  validates_uniqueness_of :name, scope: :project, message: ": Samples within the same project must have unique names."

  validates :name, presence: true
  validates :project, presence: true
  validates :user_id, presence: true
  
  def get_property key
    # Look up fields according to sample type field structure
    st = self.sample_type
    (1..8).each do |i|
      n = "field#{i}name"
      if st[n] == key
        return self["field#{i}"]
      end
    end
    return nil
  end

end
