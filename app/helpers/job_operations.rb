module JobOperations

  def set_op_status str
    operations.each do |op|
      op.status = str
      op.save
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