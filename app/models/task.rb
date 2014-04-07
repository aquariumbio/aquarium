class Task < ActiveRecord::Base

  attr_accessible :name, :specification, :status, :task_prototype_id
  belongs_to :task_prototype

  validates :name, :presence => true
  validates :status, :presence => true
  validates_uniqueness_of :name, scope: :task_prototype_id

  validate :matches_prototype

  def matches_prototype

    begin
      spec = JSON.parse self.specification, symbolize_keys: true
    rescue Exception => e
      errors.add(:json, ": Error parsing JSON in prototype. #{e.to_s}")
      return
    end

    proto = JSON.parse TaskPrototype.find(self.task_prototype_id).prototype, symbolize_keys: true

    type_check proto, spec

  end

  def type_check p, s

    case p

      when String

        result = (s.class == String)
        errors.add(:constant, ": Wrong atomic type encountered") unless result 

      when Fixnum, Float

        result = (s.class == Fixnum || s.class == Float)
        errors.add(:constant, ": Wrong atomic type encountered") unless result 

      when Hash

        result = (s.class == Hash)
        errors.add(:hash, ": Type mismatch") unless result 

        # check all requred key/values are present
        if result
          p.keys.each do |k|
            result = result && s.has_key?(k) && type_check( p[k], s[k] )
            errors.add(:missing_key_value, ": Specification is missing the key #{k}, or the value for that key has the wrong type") unless result 
          end
        end

        # check that no other keys are present
        if result
            s.keys.each do |k|
            result = result && p.has_key?(k)
            errors.add(:extra_key, ": Specification has the key #{k} but prototype does not") unless result 
          end
        end

        when Array

          result = (s.class == Array && s.length >= p.length )
          errors.add(:array, ": #{s} is not an array, or is not an array of length at last #{p.length}") unless result 

          # check that elements in spec match those in prototype 
          (0..p.length-1).each do |i|
            result = result && type_check( p[i], s[i] )
            errors.add(:array, ": Specification has mismatch at element #{i} of #{s}") unless result 
          end          

          # check that extra elements in spec match last in prototype
          if result && p.length > 0 && s.length > p.length
            ( p.length-1 .. s.length-1 ).each do |i|
              result = result && type_check( p.last, s[i] )
              errors.add(:array, ": Specification has mismatch at element #{i} of #{s}. Its type should match the type of the last element of p") unless result 
            end
          end

        else
          errors.add(:type_check, ": Unknown type in task prototype: #{p.class}")
          result = false

      end

    result

  end

end
