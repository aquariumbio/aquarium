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
  validate :legal_status

  validate :valid_task

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

  def valid_task

    # Check for legal json
    begin
      spec = JSON.parse self.specification, symbolize_names: true
    rescue Exception => e
      errors.add(:task_json, "Error parsing JSON in prototype. #{e.to_s}")
      return
    end

    # check that it matches the task prototype
    proto = JSON.parse TaskPrototype.find(self.task_prototype_id).prototype, symbolize_names: true

    unless type_check proto, spec
      errors.add(:task_prototype, "Task specification does not match prototype")
    end

    # run the user specified validation, if there is one

    # begin
    #   tv = Krill::TaskValidator.new self
    #   result = tv.check
    # rescue Exception => e
    #   errors.add(:validator_exec_error,e.to_s)
    #   return 
    # end

    # unless result == true
    #   if result.class == Array
    #     result.each do |e|
    #       logger.info e
    #       errors.add(tv.name, e)
    #     end
    #   else
    #     logger.info "Validator returned non-true, non-array value"
    #     errors.add(tv.name, "Returned non-true, non-array value.")
    #   end
    # end

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

  def self.okay_to_drop? task, user

    warn "Could not find task"                                                      and return false unless task
    warn "Not allowed to delete task #{task.id}"                                    and return false unless task.user_id == user.id
    warn "Could not delete task #{task.id} because it has associated jobs"          and return false unless task.touches.length == 0
    warn "Could not delete task #{task.id} because it has associated posts"         and return false unless task.posts.length == 0
    warn "Could not delete task #{task.id} because it has associated notifications" and return false unless task.notifications.length == 0        

    true

  end   

  def after_save_setup

    begin
      sha = Repo.version(self.task_prototype.after_save)
    rescue Exception => e
      return
    end

    code = Repo.contents self.task_prototype.after_save, sha
    eval "module TempAfterSaveModule; #{code}; end; self.extend(TempAfterSaveModule)"

    if self.respond_to?:after_save
      self.after_save
    end

  end 

  def size
    begin
      n = size_aux
    rescue Exception => e
      Rails.logger.info "Error: e.full_messages.join(', ')"
      n = 0.123
    end
    n
  end

  def size_aux

    case task_prototype.name

      when "Fragment Construction"
        spec[:"fragments Fragment"].length

      when "Gibson"
        1

      when "Gibson Assembly"
        1

      when "Plasmid Verification"
        n = spec[:"plate_ids E coli Plate of Plasmid"].length
        (0..n-1).collect { |i| spec[:"num_colonies"][i]*spec[:"primer_ids Primer"][i].length }.inject{ |sum,x| sum+x }         

      when "Sequencing"
        n = spec[:"plasmid_stock_id Plasmid Stock|Fragment Stock"].length
        (0..n-1).collect { |i| spec[:"primer_ids Primer"][i].length }.inject{ |sum,x| sum+x }        

      when "Yeast Strain QC"
        n = spec[:"yeast_plate_ids Yeast Plate"].length
        (0..n-1).collect { |i| spec[:"num_colonies"][i] }.inject{ |sum,x| sum+x }

      when "Yeast Transformation"
        spec[:"yeast_transformed_strain_ids Yeast Strain"].length

      when "Primer Order"
        spec[:"primer_ids Primer"].length        

      when "Glycerol Stock"
        spec[:"item_ids Yeast Plate|Yeast Overnight Suspension|TB Overnight of Plasmid|Overnight suspension"].length  

      when "Discard Item"
        spec[:"item_ids Item"].length          

      when "Streak Plate"
        spec[:"item_ids Yeast Glycerol Stock"].length    

      when "Sequencing Verification"
        spec[:"plasmid_stock_ids Plasmid Stock"].length + spec[:"overnight_ids TB Overnight of Plasmid"].length

      when "Yeast Competent Cell"
        spec[:"yeast_strain_ids Yeast Strain"].length

      else
        1

    end

  end

end
