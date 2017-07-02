require "rails_helper"

RSpec.describe "Planner" do

  context "mysql" do

    it "goes fast" do

      ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

      p = Plan.find(2)
      ops = p.operations.includes(:operation_type)
      fvs = FieldValue.includes(:child_sample, :child_item, :wires_as_source, :wires_as_dest)
                      .where(parent_class: "Operation", parent_id: ops.collect {|o| o.id })
    
      sops = []

      ops.each do |op|

        sop = {
          id: op.id,
          operation_type_id: op.operation_type.id,
          user_id: op.user_id,
          created_at: op.created_at,
          updated_at: op.updated_at,
          inputs: fvs.select { |fv| fv.role == "input" && fv.parent_id == op.id },
          outputs: fvs.select { |fv| fv.role == "output" && fv.parent_id == op.id }
        }

        sops << sop

      end

      sops.each do |sop|
        puts sop.inspect
      end

    end

  end

end