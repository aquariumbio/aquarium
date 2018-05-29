# frozen_string_literal: true

class Interpreter

  def initialize(protocol, arguments)
    @protocol = protocol
    @pc = 0
    @scope = Scope.new base: arguments
  end

  def current
    @protocol[@pc].render
  end

  def clear
    # print "\e[2J\e[f"
  end

  def banner
    clear
    puts "PDL Interpreter (v0.1). PC = #{@pc}."
    puts "---------------------------------------------------------------------------\n"
  end

  def step

    ins = @protocol.program[@pc]

    if ins.respond_to?('render')
      banner
      ins.render @scope
    end

    ins.execute @scope if ins.respond_to?('execute')

    if ins.respond_to?('set_pc')
      @pc = ins.set_pc @scope
    else
      @pc += 1
    end

  end

  def run

    # get argument values
    @protocol.args.each do |arg|
      banner
      print "Enter value for #{arg.var} (#{arg.description}): "
      input = gets
      puts 'In interpreter ARG TYPE is '
      puts arg.type
      if arg.type == 'num'
        puts 'The arg is a NUM'
        @scope.set arg.var.to_sym, input.chomp.to_i

      elsif arg.type == 'string'
        puts 'The arg is a STRING'
        @scope.set arg.var.to_sym, input.chomp
      end
    end

    # run program
    step while @pc < @protocol.program.length

  end

end
