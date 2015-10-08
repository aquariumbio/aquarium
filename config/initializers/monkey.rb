 class Array

  def conjoin &block
    temp = self.collect &block
    temp.inject(true) { |a,b| a && b } 
  end

  def disjoin &block
    temp = self.collect &block
    temp.inject(false) { |a,b| a || b } 
  end  

end

class String

  def as_sample_id
    self.split(":")[0]
  end

end