module Oyster

  class Parser

    def add_time_function name, num_args
      if !@tfunctions
        @tfunctions = {}
      end
      @tfunctions[name] = num_args
    end

    def time_functions

      add_time_function :now, 0
      add_time_function :today_at, 2     # hours, minutes
      add_time_function :tomorrow, 0
      add_time_function :tomorrow_at, 2  # hours, minutes

      add_time_function :minutes, 1
      add_time_function :hours, 1
      add_time_function :days, 1

    end

    def time

      name = @tok.eat_a_variable
      e = name

      unless @tfunctions[name.to_sym]
        raise "Unknown time function '#{name}'"
      end

      e += @tok.eat_a '('
      (1..@tfunctions[name.to_sym]).each do |i|
        e += expr
        if i < @tfunctions[name.to_sym]
          e += @tok.eat_a ','
        end
      end

      e += @tok.eat_a ')'

      e

    end

  end

end
