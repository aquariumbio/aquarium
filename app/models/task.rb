class Task < ActiveRecord::Base

  attr_accessible :name, :specification, :status, :task_prototype_id, :user_id
  belongs_to :task_prototype
  has_many :touches
  has_many :post_associations
  has_many :task_notifications
  belongs_to :user

  validates :name, :presence => true
  validates :status, :presence => true
  validates_uniqueness_of :name, scope: :task_prototype_id

  validate :matches_prototype

  validate :legal_status

  def legal_status
    begin
      if ! JSON.parse(self.task_prototype.status_options).include? self.status
        errors.add(:status_choice, "Status must be one of " + self.task_prototype.status_options);
        return
      end
    rescue Exception => e 
      errors.add(:status_udpate, "Could not update status: #{e.to_s}")
      return
    end
  end

  def matches_prototype

    begin
      spec = JSON.parse self.specification, symbolize_names: true
    rescue Exception => e
      errors.add(:task_json, "Error parsing JSON in prototype. #{e.to_s}")
      return
    end

    proto = JSON.parse TaskPrototype.find(self.task_prototype_id).prototype, symbolize_names: true

    unless type_check proto, spec
      errors.add(:task_prototype, "Task specification does not match prototype")
    end

  end

  def type_check p, s

    # puts "CHECKING #{s} against #{p}"

    case p

      when String

        result = (s.class == String)
        # puts "wrong atomic 1" unless result
        errors.add(:task_constant, ": Wrong atomic type encountered") unless result 

      when Fixnum, Float

        result = (s.class == Fixnum || s.class == Float)
        # puts "wrong atomic 1" unless result
        errors.add(:task_constant, ": Wrong atomic type encountered") unless result 

      when Hash

        result = (s.class == Hash)
        errors.add(:task_hash, ": Type mismatch") unless result 

        # check all requred key/values are present
        if result
          p.keys.each do |k|
            result = result && has_consistent_key?(s,k) && type_check( get_part(p,k), get_part(s,k) )
            errors.add(:task_missing_key_value, ": Specification #{s} is missing the key '#{k}' (a #{k.class})") unless result   
            errors.add(:task_missing_key_value, ": Specification #{s[k]} has the wrong type. Should match #{p[k]}") unless result
          end
        end

        # check that no other keys are present
        if result
            s.keys.each do |k|
              result = result && has_consistent_key?(p,k)
              errors.add(:task_extra_key, ": Specification has the key #{k} but prototype does not") unless result 
            end
        end

        when Array

          result = (s.class == Array && s.length >= p.length )
          errors.add(:task_array, ": #{s} is not an array, or is not an array of length at last #{p.length}") unless result 

          # check that elements in spec match those in prototype 
          (0..p.length-1).each do |i|
            result = result && type_check( p[i], s[i] )
            errors.add(:task_array, ": Specification has mismatch at element #{i} of #{s}") unless result 
          end          

          # check that extra elements in spec match last in prototype
          if result && p.length > 0 && s.length > p.length
            ( p.length-1 .. s.length-1 ).each do |i|
              result = result && type_check( p.last, s[i] )
              errors.add(:task_array, ": Specification has mismatch at element #{i} of #{s}. Its type should match the type of the last element of p") unless result 
            end
          end

        else
          errors.add(:task_type_check, ": Unknown type in task prototype: #{p.class}")
          result = false

      end

    result

  end

  def get_part spec,key

    name = key.to_s.split(' ')[0]

    spec.each do |k,v|
      sname = k.to_s.split(' ')[0]
      if name == sname
        return v
      end
    end

    return nil

  end

  def has_consistent_key?(s,k) 

    # puts "checking specification #{s} for existence of #{k}"

    name = k.to_s.split(' ')[0]
    types = k.to_s.split(' ')[1,100].join(' ').split('|')
    found = false

    s.each do |key,val| 
      sname = key.to_s.split(' ')[0]
      stypes = key.to_s.split(' ')[1,100].join(' ').split('|')
      # puts "  checking if #{name} == #{sname} and #{stypes} is a subset of #{types}" unless found
      if name == sname && ( stypes.all? { |i| types.include?(i) } || types.all? { |i| stypes.include?(i) } )
        found = true
        # puts "  #{name} is okay"
      end
    end

    # puts "  #{name} is not okay" unless found

    found

  end

  def spec

    unless defined?(@parsed_spec)

      begin
        @parsed_spec = JSON.parse self.specification, symbolize_names: true
      rescue Exception => e
        @parsed_spec = { warnings: [ "Failed to parse task specification", e ]}
      end

    end

    @parsed_spec

  end

  def simple_spec

    Job.new.remove_types spec

  end

  def num_posts
    self.post_associations.count
  end

  def export
    attributes
  end

  def mentions? sample # returns true if any field of the task specification refers to 
                      # this particular sample

    return mentions_aux spec, sample.id, sample.sample_type.name

  end

  def mentions_aux sp, sample_id, sample_type_name

    if sp.class == Hash

      sp.each do |k,v|

        name,type = k.to_s.split(' ')

        if type
          types = type.split('|')
          if types.member? sample_type_name
            if v.class == Array
              return v.member? sample_id
            else
              return sample_id == v
            end
          else 
            return false
          end
        else
          return mentions_aux v, sample_id, sample_type_name
        end

      end

    else

      return false

    end

  end

  def notify msg, opts={}

    tn = TaskNotification.new( { 
      task_id: self.id, 
      content: msg, 
      job_id: nil, 
      read: false }.merge opts )

    tn.save

  end

  def notifications
    task_notifications
  end

end
