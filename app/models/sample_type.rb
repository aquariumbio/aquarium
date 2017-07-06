class SampleType < ActiveRecord::Base

  include FieldTyper

  after_destroy :destroy_fields

  attr_accessible :description, :name

  has_many :samples
  has_many :object_types

  validates :name, presence: true
  validates :description, presence: true

  def export
    attributes
  end

  def required_sample_types st_list=[]

    field_types.select { |ft| ft.ftype == 'sample' }.each do |ft|

      ft.allowable_field_types.each do |aft|

        if aft.sample_type && !st_list.member?(aft.sample_type)
          st_list << aft.sample_type
          st_list = aft.sample_type.required_sample_types(st_list)
        end

      end

    end

    st_list

  end

  def self.check_for raw_sample_types

    raw_sample_types.each do |rst|

      print "Checking for #{rst[:name]} ... "
      if find_by_name(rst[:name])
        puts "found"
      else
        puts "not found"
      end

    end

  end

end
