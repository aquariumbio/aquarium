# Name
# Sample Type [e.g. Plasmid]
# Sample Name [e.g. pABC]
# Container Name [e.g. Stripwell]
# Item number(s)
# Part of Collection? [Yes|No]
# Dimension [Scalar, n, nxm]
# Shared? [Yes|No]

class Ispec

  attr_accessor :name, :sample_type, :sample, :container, :item, :is_part, :dimension, :is_shared, :row, :col

  def initialize attrs={}
    assign_attrs attrs
  end

  def assign_attrs attrs
    attrs.keys.each do |key|
      m = "#{key}="
      self.send( m, attrs[key].class == Fixnum ? [attrs[key]] : attrs[key] ) if self.respond_to?( m )
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
 
    if self.dimension

      num_rows = self.dimension[0]
      num_cols = self.dimension[1]

      return false unless i.class == Array && i.length == num_rows

      (0..num_rows-1).each do |x|
        return false unless i[x].class == Array && i[x].length == num_cols
        (0..num_cols-1).each do |y|
          element = Ispec.new(get_attrs.except :dimension)
          sat &&= element.satisfied_by?(i[x][y])
        end
      end

    elsif is_part

      return false unless i.class == Part # Part = { collection, x, y }

      sat &&= ( self.container[0] == i.collection.object_type.id ) if self.container
      sat &&= ( self.item[0] == i.collection.id ) if self.item
      sat &&= ( self.sample_type[0] == i.sample.sample_type.id ) if self.sample_type
      sat &&= ( self.sample[0] == i.sample.id ) if self.sample

    else

      sat &&= ( self.item.member? i.id ) if self.item
      sat &&= ( self.container.member? i.object_type.id ) if self.container
      sat &&= ( self.sample.member? i.sample.id ) if self.sample
      sat &&= ( self.sample_type.member? i.sample.sample_type.id ) if self.sample_type    

    end

    sat

  end

end
