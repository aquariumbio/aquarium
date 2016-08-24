module JobOperations

  def set_op_status str, force=false
    operations.each do |op|
      if op.status != "error" || force 
        Rails.logger.info "#{op.id}: SETTING STATUS FROM #{op.status} to #{str}"
        op.set_status str
      else
        Rails.logger.info "#{op.id}: DID NOT SET STATUS BECUASE IT WAS ALREADY 'error'"
      end
    end
  end

  def start
    if self.pc == Job.NOT_STARTED
      self.pc = 0
      save
      set_op_status "running"
    end
  end

  def stop status="done"
    if self.pc >= 0
      self.pc = Job.COMPLETED
      save
      set_op_status status
      Operation.step
    end
  end

end