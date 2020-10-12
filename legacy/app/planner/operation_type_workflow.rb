# typed: false
# frozen_string_literal: true

module OperationTypeWorkflow

  def predecessors

    preds = []

    OperationType.all.each do |ot|

      inputs.each do |input|

        ot.outputs.each do |output|

          input.allowable_field_types.each do |input_aft|

            output.allowable_field_types.each do |output_aft|

              # if output can produce inputs of type input
              next unless input_aft.sample_type_id == output_aft.sample_type_id &&
                          input_aft.object_type_id == output_aft.object_type_id

              preds << {
                operation_type_id: ot.id,
                sample_type_id: input_aft.sample_type_id,
                object_type_id: input_aft.object_type_id
              }

            end

          end

        end

      end

    end

    preds

  end

end
