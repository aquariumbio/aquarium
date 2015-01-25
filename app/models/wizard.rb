class Wizard < ActiveRecord::Base
  attr_accessible :name, :specification, :description
  validates :name, presence: true
  validates :description, presence: true
  validates_uniqueness_of :name

  def spec 

    if self.specification

      s = JSON.parse(self.specification,symbolize_names:true)
      t = []

      s[:fields].each do |k,v|
        vnew = { name: v[:name], min: v[:min].to_i, max: v[:max].to_i}
        t[k.to_s.to_i] = vnew
      end

      s[:fields] = t

      s

    else

      {}

    end

  end

end
