module Krill

  # A class that makes making tables for calls to 'show' easier.
  # @example Create a table, add rows, and display it.
  #   t = Table.new(
  #     a: "First column",
  #     b: "Second column"
  #   )
  #   
  #   t.a(1).b(2).append
  #   t.a(3).b(4).append
  #
  #   show do
  #     table t.all.render
  #   end
  class Table

    # Create a table object, which makes making tables for calls to 
    # show easier.
    #
    # @param [Hash] columns A list hash of the form { a: String, b: String, ... } defining the columns of the table and their headings.
    #
    # @return [Table] A Table object.
    #
    def initialize columns={}
      @columns = columns
      @selection = {}
      @rows = []
      @choice = []
      @from = 0
      @to = 100000
    end

    # Add a column to the table.
    #
    # @param [symbol] name The name of the column.
    # @param [String] heading A string to use for the heading of the column.
    # @return [Table] The table with the heading added to it, can be chained.
    def column name, heading
      @columns[name] = heading
      self
    end

    def has_columns?
      !@columns.keys.empty?
    end

    def has_column? key
      @columns[key] != nil
    end    

    # Set a value in the current row
    #
    # @param [symbol] name The name of the column
    # @param [] value Value to set
    def set name, value
      @selection[name] = value   
      self
    end

    # Clear the currently selected columns, and result from and to.
    # @return [Table] The table, can be chained.
    def clear
      @selection = {}
      @from = 0
      @to = 100000
      self
    end

    # Append a row defined by the currently selectors.
    # @return [Table] The table, can be chained.    
    def append
      @rows << @selection
      clear
      self
    end

    # Select all columns.
    # @return [Table] The table, can be chained. 
    def all
      @choice = @columns.keys
      self
    end

    # Choose which columns to display in a subsequent call to render.
    # @param [Array] columns An array of column names, as in [:x, :y, :z].    
    # @return [Table] The table, can be chained.
    def choose columns
      @choice = columns
      self
    end

    # Define the row to start with in a subsequent call to render.
    # @param [Fixnum] i The column to start with.
    # @return [Table] The table, can be chained.
    def from i
      raise "Table: from(#{i}) is out of range" unless i < @rows.length
      @from = i
      self
    end

    # Define the row to end with (actually i-1) in a subsequent call to render.
    # @param [Fixnum] i The column to end just before.
    # @return [Table] The table, can be chained.
    def to i
      @to = i
      self
    end

    # Return a matrix (Array or Arrays) representing the table for use in a call to 'show'.
    # @return [Array] The table as an array or arrays.
    def render

      heading = @choice.collect { |c| @columns[c] }

      body = (@from..[@to,@rows.length].min-1).collect do |i|
        @choice.collect { |c| @rows[i][c] }
      end

      [ heading ] + body

    end

    private

    # @private
    # Each column in the table can be used as a method.
    # 
    # @example Suppose a table t has a row named :x. Then you can do
    #   t.x("whatever").append
    def method_missing m, *args, &block

      if @columns[m]
        set(m,args[0])
      else
        super
      end

    end    

  end

end