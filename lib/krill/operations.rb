module Krill

  module Base

    def operations

      Operation.has_many :fvs, foreign_key: "parent_id", class_name: "FieldValue"

      @operations ||= Operation.includes(:operation_type, fvs: [:field_type, :child_sample, :child_item]).where(job_id: jid)
      @operations

    end

  end

end