class Collection < ActiveRecord::Base

  attr_accessible :columns, :name, :object_type_id, :project, :rows

  belongs_to :object_type
  has_many :parts

  def matrix

    m = []
    rows.times { m.push [] }

    (1..rows).each do |r|
      (1..columns).each do |c|
        m[r-1][c-1] = parts.reject { |p| p.row != r || p.column != c }
      end
    end

    return m

  end

end
