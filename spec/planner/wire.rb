# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Planner' do

  context 'wires' do

    it 'works' do

      # build_workflow

      primer = SampleType.find_by_name('Primer').samples.sample

      op1 = OperationType.find_by_name('Order Primer').operations.create status: 'planning'
      op1.set_output('Primer', primer)

      op2 = OperationType.find_by_name('Receive Primer').operations.create status: 'planning'
      op2.set_input('Primer', primer)
         .set_output('Primer', primer)

      op2.inputs[0].add_predecessor(op1.outputs[0])

      # w = Wire.new(from_id: op1.outputs[0].id, to_id: op2.inputs[0].id)
      # w.save

      puts "wires = #{Wire.all}"
      puts "op1 #{op1.id} source wires = #{op1.outputs[0].wires_as_source}"
      puts "op2 #{op2.id} dest wires = #{op2.inputs[0].wires_as_dest}"

      puts op1.outputs[0].successors.collect(&:inspect)
      puts op2.inputs[0].predecessors.collect(&:inspect)

    end

  end

end
