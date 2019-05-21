# frozen_string_literal: true

# @api krill
module Krill

  # @api krill
  module OperationList

    # @api krill
    # Begin building a table from {OperationList}
    # @option opts [Bool] :errored Include {Operation}s with status "error"
    # @example Make a table for pipetting primers into a stripwell for PCR
    #  table operations.start_table
    #    .output_collection("Fragment", heading: "Stripwell")
    #    .custom_column(heading: "Well") { |op| op.output("Fragment").column + 1 }
    #    .input_item(FWD, heading: "Forward Primer, 2.5 µL", checkable: true)
    #    .input_item(REV, heading: "Reverse Primer, 2.5 µL", checkable: true)
    #  .end_table
    # @return {Array} extended with {OperationList}
    def start_table(_opts = { errored: false })
      @table = Table.new
      self
    end

    # Finish building a table
    # @see #start_table
    def end_table
      @table
    end

    def property(op, method_name, name, role, checkable)

      fv = op.get_field_value name, role

      if checkable
        fv ? { content: fv.send(method_name), check: true } : '?'
      else
        fv ? fv.send(method_name) : '?'
      end

    end

    # Add column with input/output {Item} ids
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option heading [String] Column heading (defaults to input/output name)
    # @option checkable [Bool] Column cells can be clicked
    # @see #input_item
    # @see #output_item
    def item(name, role, opts = {})
      @table.add_column(opts[:heading] || "#{name} Item ID (#{role})", running.collect do |op|
                                                                         property op, :item_link, name, role, opts[:checkable]
                                                                       end)
      self
    end

    # Add column with input/output {Sample} ids
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option heading [String] Column heading (defaults to input/output name)
    # @option checkable [Bool] Column cells can be clicked
    # @see #input_sample
    # @see #output_sample
    def sample(name, role, opts = {})
      @table.add_column(opts[:heading] || "#{name} Sample ID (#{role})", running.collect do |op|
                                                                           property op, :child_sample_id, name, role, opts[:checkable]
                                                                         end)
      self
    end

    # Add column with input/output {Collection} ids
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option heading [String] Column heading (defaults to input/output name)
    # @option checkable [Bool] Column cells can be clicked
    # @see #input_collection
    # @see #output_collection
    def collection(name, role, opts = {})
      entries = running.collect do |op|
        property op, :child_item_id, name, role, opts[:checkable]
      end
      heading = opts[:heading] || "#{name} Collection ID (#{role})"
      @table.add_column(heading, entries)
      self
    end

    # Add column with input/output row (if part of a {Collection})
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option heading [String] Column heading (defaults to input/output name)
    # @option checkable [Bool] Column cells can be clicked
    # @see #input_row
    # @see #output_row
    def row(name, role, opts = {})
      @table.add_column(opts[:heading] || "#{name} Row (#{role})", running.collect do |op|
        property op, :row, name, role, opts[:checkable]
      end)
      self
    end

    # Add column with input/output column (if part of a {Collection})
    # @param name [String] Input/Output name
    # @param role [String] ("input", "output")
    # @param opts [Hash]
    # @option heading [String] Column heading (defaults to input/output name)
    # @option checkable [Bool] Column cells can be clicked
    # @see #input_column
    # @see #output_column
    def column(name, role, opts = {})
      @table.add_column(opts[:heading] || "#{name} Column (#{role})", running.collect do |op|
        property op, :column, name, role, opts[:checkable]
      end)
      self
    end

    # Add column with custom content
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option checkable [Bool] Column cells can be clicked
    def custom_column(opts = { heading: "Custom Column", checkable: false }, &block)
      entries = running.collect(&block).collect do |x|
        opts[:checkable] ? ({ content: x, check: true }) : x
      end
      @table.add_column(opts[:heading], entries)

      self
    end

    def operation_id(opts = { heading: 'Operation ID', checkable: false })
      @table.add_column(opts[:heading], running.collect(&:id))

      self
    end

    # Add column with list of input items by the given input name
    #
    # @param name [String]  the name of the input to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def input_item(name, opts = {}); item name, "input", opts; end

    # Add column with list of output items by the given output name
    #
    # @param name [String]  the name of the output to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def output_item(name, opts = {}); item name, "output", opts; end

    # Add column with list of input samples by the given input name
    #
    # @param name [String]  the name of the input to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def input_sample(name, opts = {}); sample name, "input", opts; end

    # Add column with list of ouput samples by the given ouput name
    #
    # @param name [String]  the name of the ouput to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def output_sample(name, opts = {}); sample name, "output", opts; end

    # Add column with list of input collection by the given input name
    #
    # Input by the given name is either a part or a collection
    # @param name [String]  the name of the input to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def input_collection(name, opts = {}); collection name, "input", opts; end

    # Add column with list of ouput collection by the given ouput name
    #
    # Output by the given name is either a part or a collection
    # @param name [String]  the name of the ouput to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def output_collection(name, opts = {}); collection name, "output", opts; end

    # Add column with list of input row indicies by the given input name
    #
    # Input by the given name is a part
    # @param name [String]  the name of the input to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def input_row(name, opts = {}); row name, "input", opts; end

    # Add column with list of output row indicies by the given output name
    #
    # Output by the given name is a part
    # @param name [String]  the name of the output to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def output_row(name, opts = {}); row name, "output", opts; end

    # Add column with list of input column indicies by the given input name
    #
    # Input by the given name is a part
    # @param name [String]  the name of the input to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def input_column(name, opts = {}); column name, "input", opts; end

    # Add column with list of output row indicies by the given output name
    #
    # Output by the given name is a part
    # @param name [String]  the name of the output to display
    # @param opts [Hash]
    # @option heading [String] Column heading
    # @option clickable [Bool] Column cells can be clicked
    def output_column(name, opts = {}); column name, "output", opts; end

    # Append a column to the OperationList Table that accepts user input
    #
    # @param key ["String"]  the name of the key where the input data will be stored
    # @param opts [Hash]  Additional options
    # @option type [String]  defines type of user input -- can be either 'number' or 'text'
    # @option default [String, Number]  fill table with a default value
    def get(key, opts)
      @table.add_column(opts[:heading] || key.to_s, running.collect do |op|
        { type: opts[:type] || 'number', operation_id: op.id, key: key, default: opts[:default] || 0 }
      end)
      self
    end

    def result(key, opts = {})
      @table.add_column(opts[:heading] || key.to_s, running.collect do |op|
        { content: op.temporary[key], check: opts[:checkable] }
      end)
      self
    end

  end

end
