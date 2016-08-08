module Krill

  module Base

    def operations

      @operations ||= Operation.includes(:operation_type).where(job_id: jid)
      @operations

    end

  end

end