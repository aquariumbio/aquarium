module Krill

  module Base

    def operations opts={force:false}

      if opts[:force]
        @operations = Operation.includes(:operation_type).where(job_id: jid)
      else
        @operations ||= Operation.includes(:operation_type).where(job_id: jid)
      end

      @operations.extend(OperationList)
      @operations.protocol = self
      @operations.length # force db query

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

  end

end