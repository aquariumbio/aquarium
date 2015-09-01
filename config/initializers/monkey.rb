 class Array

  def conjoin &block
    temp = self.collect &block
    temp.inject(true) { |a,b| a && b } 
  end

end