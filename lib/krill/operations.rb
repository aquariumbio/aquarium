module Krill

  module Base

    def operations

      @operations ||= Operation.includes(:operation_type).where(job_id: jid)
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