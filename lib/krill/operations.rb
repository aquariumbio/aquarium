module Krill

  module Base

    def operations opts={force:false}

      if opts[:force] || !@operations
        op_ids = JobAssociation.where(job_id: jid).collect { |ja| ja.operation_id }       
        @operations = Operation.includes(:operation_type).find(op_ids)
        @operations.extend(OperationList)
        @operations.protocol = self
        @operations.length # force db query
      end

      @operations

    end

    def operation_type

      ops = operations

      if ops.length > 0
        ops[0].operation_type
      else
        nil
      end

    end

    def insert_operation index, element
      before = @operations[0,index]
      after = @operations[index,@operations.length-index]
      @operations = before + [element] + after
      @operations
    end

  end

end