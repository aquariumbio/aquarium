class Alternative

  attr_accessor :sample_type, :container, :sample, :item, :row, :column

  def initialize attrs={}
    assign_attrs attrs
  end

  def assign_attrs attrs
    attrs.keys.each do |key|
      m = "#{key}="
      self.send( m, attrs[key] ) if self.respond_to?( m )
    end
  end

  def satisfied_by_item? i

    sat = true

    sat &&= ( self.item == i.id )                           if self.item
    sat &&= ( self.container == i.object_type.id )          if self.container
    sat &&= ( self.sample == i.sample.id )                  if self.sample
    sat &&= ( self.sample_type == i.sample.sample_type.id ) if self.sample_type    

    sat

  end

  def satisfied_by_part? p

    sat = true

    return false unless p.class == Part 

    sat &&= ( self.container == p.collection.object_type.id ) if self.container
    sat &&= ( self.item == p.collection.id )                  if self.item
    sat &&= ( self.sample_type == p.sample.sample_type.id )   if self.sample_type
    sat &&= ( self.sample == p.sample.id )                    if self.sample
    sat &&= ( self.row == p.x )                               if self.row
    sat &&= ( self.column == p.y )                            if self.column    

    sat

  end

end

class Ispec

  attr_accessor :name, :alternatives, :item, :rows, :columns
  attr_accessor :is_part, :is_shared, :is_matrix

  def initialize attrs={}
    assign_attrs attrs
  end

  def assign_attrs attrs
    attrs.keys.each do |key|
      if key == :alternatives
        self.alternatives = attrs[key].collect { |a|
          a.class == Alternative ? a : (Alternative.new a)
        }
      else
        m = "#{key}="
        self.send( m, attrs[key] ) if self.respond_to?( m )
      end
    end
  end

  def get_attrs

    attrs = Hash.new
    instance_variables.each do |var|
      str = var.to_s.gsub /^@/, ''
      if respond_to? "#{str}="
        attrs[str.to_sym] = instance_variable_get var
      end
    end
    attrs

  end

  def unify ispec

  end

  def instantiate limit=1

  end

  def satisfied_by? i

    sat = true
 
    if self.is_matrix

      raise "rows and/or columns not defined" unless self.rows && self.columns

      return false unless i.class == Array && i.length <= self.rows

      (0..i.length-1).each do |x|
        return false unless i[x].class == Array && i[x].length <= self.columns
        (0..i[x].length-1).each do |y|
          element = Ispec.new(get_attrs.except :is_matrix, :rows, :columns)
          sat &&= element.satisfied_by?(i[x][y])
        end
      end

    elsif is_part
      sat &&= self.alternatives.inject(false) { |sum,a| sum || ( a.satisfied_by_part? i ) }
    else
      sat &&= self.alternatives.inject(false) { |sum,a| sum || ( a.satisfied_by_item? i ) }
    end

    sat

  end



end
