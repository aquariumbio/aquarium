module Krill

  class Table

    def initialize columns
      @columns = columns
      @selection = {}
      @rows = []
      @choice = []
      @from = 0
      @to = 0
    end

    def column name, heading
      @columns[name] = heading
    end

    def clear
      @selection = {}
      @from = 0
      @to = 0
      self
    end

    def method_missing m, *args, &block

      if @columns[m]
        @selection[m] = args[0]
        self
      else
        super
      end

    end

    def append

      @rows << @selection
      clear
      self

    end

    def choose columns
      @choice = columns
      self
    end

    def from i
      raise "Table: from(#{i}) is out of range" unless i < @rows.length
      @from = i
      self
    end

    def to i
      @to = i
      self
    end

    def render

      heading = @choice.collect { |c| @columns[c] }

      body = (@from..[@to,@rows.length].min-1).collect do |i|
        @choice.collect { |c| @rows[i][c] }
      end

      [ heading ] + body

    end

  end

end