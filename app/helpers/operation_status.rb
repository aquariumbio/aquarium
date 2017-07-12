module OperationStatus

  def change_status str
    temp = self.status
    self.status = str
    self.save
    puts "changed status of operation #{id} from #{temp} to #{str}, with errors = [#{errors.full_messages.join(', ')}]"
    raise "Could not change status" unless errors.empty?
    return str
  end

  def start 

    raise "Cannot start operation #{id} from state #{status}" unless status == "planning"

    if on_the_fly
      change_status "primed"
    elsif leaf? # note that this op is considered a leaf if it has no preds, 
                # or if its preds are all on_the_fly leaves
      change_status "pending"
    elsif
      change_status "waiting"
    end

  end

  def schedule
    raise "Cannot schedule operation #{id} from state #{status}" unless status == "pending" || status == "deferred" || status == "primed"
    change_status "scheduled"
  end

  def run
    raise "Cannot run operation #{id} from state #{status}" unless status == "scheduled"
    change_status "running"
  end

  def defer
    raise "Cannot defer operation #{id} from state #{status}" unless status == "pending"
    change_status "deferred"
  end    

  def unbatch
  end

  def step # not to be confused with def self.step in Operation.rb

    begin
      if ready?
        if on_the_fly
          change_status "primed"
        elsif status == "deferred"
          change_status "scheduled"
        else
          change_status "pending"
        end
      end
    rescue Exception => e
      Rails.logger.info "COULD NOT STEP OPERATION #{op.id}: #{e.to_s}"
    end    

    # TODO: Change deferred op to scheduled 

  end

  def finish
    change_status "done" if self.status != "error"
  end

  def error error_type, msg
    change_status "error"
    associate error_type, msg
  end

  def redo
    change_status "pending"
    # TODO: Change preds to pending? At least on_the_fly_preds/
  end

end

