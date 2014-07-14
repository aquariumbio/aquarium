class Collection < Item

  def apportion r, c
    self.data =  (Array.new(r,Array.new(c,-1))).to_json
  end

  def associate sample_matrix

    m = JSON.parse self.data

    (0..sample_matrix.length-1).each do |r|
      (0..sample_matrix[r].length-1).each do |c|
        m[r][c] = sample_matrix[r][c]
      end
    end

    self.data = m.to_json

  end

end