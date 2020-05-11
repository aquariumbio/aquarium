# typed: true
# frozen_string_literal: true

class PlanOptimizer

  def initialize(plan)
    @plan = plan
    @ops = Operation.joins(:plan_associations).includes(:operation_type).where("plan_id = #{plan.id}")
    @size = @ops.length
    @matrix = (0..@size - 1).collect { |_i| (0..@size - 1).collect { |_j| nil } }
    @orphans = []
    @messages = []
  end

  def equivalent_fvs?(fv1, fv2)

    attrs = %i[name child_item_id child_sample_id value role
               field_type_id row column allowable_field_type_id]

    attrs.each do |a|
      return false if fv1[a] != fv2[a]
    end

    true

  end

  def equivalent_ops?(op1, op2)

    fvs1 = op1.field_values
    fvs2 = op2.field_values

    (0..fvs1.length - 1).each do |i|
      return false unless equivalent_fvs?(fvs1[i], fvs2[i])
    end

    true

  end

  def next_equiv
    (0..@size - 1).each do |i|
      (i + 1..@size - 1).each do |j|
        return [i, j] if @matrix[i][j] == 1
      end
    end
    nil
  end

  def erase(n)
    (0..@size - 1).each do |i|
      (i + 1..@size - 1).each do |j|
        @matrix[i][j] = nil if i == n || j == n
      end
    end
  end

  def print_matrix
    i = 0
    @matrix.each do |row|
      print "#{@ops[i].id}: "
      i += 1
      puts row.collect { |x| x ? x.to_s : '-' }.join(' ')
    end
  end

  def build_matrix

    (0..@size - 1).each do |i|
      (i + 1..@size - 1).each do |j|
        op1 = @ops[i]
        op2 = @ops[j]
        if op1.id != op2.id &&
           op1.operation_type.id == op2.operation_type.id &&
           equivalent_ops?(op1, op2)
          puts "#{op1.id} == #{op2.id}"
          @matrix[i][j] = 1
        else
          @matrix[i][j] = 0
        end
      end
    end

  end

  def equate(winner, loser)

    puts "equating #{winner.id} and #{loser.id}"

    winner_fvs = winner.field_values
    loser_fvs = loser.field_values

    (0..winner_fvs.length - 1).each do |i|
      win = winner_fvs[i]
      lose = loser_fvs[i]
      if lose.role == 'input'
        lose.wires_as_dest.each do |w|
          puts "rewiring input wire from #{w.from.parent_id}:#{w.from.name} to #{w.to.parent_id}:#{w.to.name}"
          w.to_id = win.id
          w.save
        end
      elsif lose.role == 'output'
        lose.wires_as_source.each do |w|
          puts "rewiring output wire from #{w.from.parent_id}:#{w.from.name} to #{w.to.parent_id}:#{w.to.name}"
          w.from_id = win.id
          w.save
        end
      end
    end

    @orphans << loser

  end

  def optimize

    build_matrix
    print_matrix

    e = next_equiv

    while e
      equate @ops[e[0]], @ops[e[1]]
      erase e[0]
      print_matrix
      e = next_equiv
    end

    @orphans.each do |o|
      @messages << "#{o.operation_type.name} #{o.id} is redundant and was removed from plan."
      PlanAssociation.where(plan_id: @plan.id,
                            operation_id: o ? o.id : nil)
                     .each(&:destroy)
      o.destroy
    end

    @messages

  end

end
