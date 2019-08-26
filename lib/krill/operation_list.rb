# frozen_string_literal: true

# @api krill
module Krill

  # @api krill
  # In protocol code, the operations method will return an OperationList, which is an
  # extension of the [Array] class.
  #
  # @example Iterate through operations
  #   operations.each do |operation|
  #     show do
  #       title "This is operation #{operation.id}"
  #     end
  #   end
  # @example Tell the technician to retrieve all required inventory, and make new inventory ids required for the protocol
  #   operations.retrieve.make
  # @example Make and display a table based on the operations input and output
  #   show do
  #     table operations.start_table
  #       .output_collection("Fragment", heading: "Stripwell")
  #       .custom_column(heading: "Well") { |op| op.output("Fragment").column + 1 }
  #       .input_item(FWD, heading: "Forward Primer, 2.5 µL", checkable: true)
  #       .input_item(REV, heading: "Reverse Primer, 2.5 µL", checkable: true)
  #       .end_table
  #   end
  module OperationList

    def protocol=(p)
      @protocol = p
    end

    def collect(&block)
      ops = super(&block)
      ops.extend(OperationList)
      ops.protocol = @protocol
      ops
    end

    def map(&block)
      ops = super(&block)
      ops.extend(OperationList)
      ops.protocol = @protocol
      ops
    end

    def select(&block)
      ops = super(&block)
      ops.extend(OperationList)
      ops.protocol = @protocol
      ops
    end

    def reject(&block)
      ops = super(&block)
      ops.extend(OperationList)
      ops.protocol = @protocol
      ops
    end

    def group_by(&block)
      grouped_ops = super(&block)
      grouped_ops = grouped_ops.map do |key, ops|
        ops.extend(OperationList)
        ops.protocol = @protocol
        [key, ops]
      end.to_h
      grouped_ops
    end

    def running
      result = select do |op|
        op.status != 'error'
      end
      result
    end

    # Select {Operation}s with status "error"
    # @return {Array} extended with {OperationList}
    def errored
      select { |op| op.status == 'error' }
    end

    # Get all items.
    # Error out any operations for which items could not be retrieved.
    # Show item retrieval instructions (unless verbose is false)
    # @param opts [Hash]
    # @option opts [Bool] :interactive Show Krill slides
    # @option opts [String] :method ("boxes") Show boxes slide
    # @option opts [Array<String>] :only Retrieve only inputs of provided names
    # @return {Array} extended with {OperationList}
    def retrieve(opts = {})
      opts = { interactive: true, method: 'boxes', only: [] }.merge opts

      items = []

      each_with_index do |op, _i|
        op_items = []
        op.inputs.select { |fv| opts[:only].empty? || opts[:only].include?(fv.name) }.each do |input|
          input.retrieve unless input.child_item || input.value
          if input.child_item_id
            op_items << input.child_item
          elsif !input.value
            op.status = 'error'
            op.save
            sname = input.child_sample ? input.child_sample.name : '-'
            oname = input.child_item ? input.child_item.object_type.name : '-'
            op.associate 'input error', "Could not find input #{input.name}: #{sname} / #{oname}"
          end
        end
        items += op_items unless op.status == 'error'
      end

      if block_given?
        @protocol.take items.uniq, opts, &Proc.new
      else
        @protocol.take items.uniq, opts
      end

      self

    end

    # Return collections produced
    # @example Find stripwells made for PCR
    #   operations.output_collections["PCR"]
    # @return [Array<Collection>]
    def output_collections
      @output_collections ||= {}
      @output_collections
    end

    # Produce items for {Operation}s
    #
    # @param custom_opts [Hash]
    # @option custom_opts [Bool] :errored Include {Operation}s with status "error"
    # @option custom_opts [String] :role "input" or "output"
    # @option custom_opts [Array<String>] :only Make only outputs of provided names
    # @return {Array} extended with {OperationList}
    def make(custom_opts = {})

      opts = { errored: false, role: 'output', only: [] }.merge custom_opts

      @output_collections = {}
      ops = select { |op| opts[:errored] || op.status != 'error' }

      ops.each_with_index do |op, i|

        op.field_values.select { |fv| fv.role == opts[:role] && (opts[:only].blank? || opts[:only].member?(fv.name)) }.each do |fv|

          if fv.part?

            rows = fv.object_type.rows || 1
            columns = fv.object_type.columns || 12

            size = rows * columns

            unless @output_collections[fv.name]
              @output_collections[fv.name] = (0..(ops.length - 1) / size).collect do |_c|
                fv.make_collection
              end
            end

            fv.make_part(@output_collections[fv.name][i / size], (i % size) / columns, (i % size) % columns)

          elsif fv.object_type && fv.object_type.handler == 'collection'

            fv.make_collection

          else

            fv.make

          end # if

        end # select/each

      end # each

      self

    end

    # Return all inputs and outputs to their locations
    # @param opts [Hash]
    # @option opts [Bool] :interactive Show Krill slides
    # @option opts [String] :method ("boxes") Show boxes slide
    # @option opts [Bool] :errored Store {Operation}s with status "error"
    # @option opts [String] :io ("all", "input", "output") Store inputs, outputs, or both
    # @return {Array} extended with {OperationList}
    def store(opts = { interactive: true, method: 'boxes', errored: false, io: 'all' })

      items = []

      select { |op| opts[:errored] || op.status != 'error' }.each_with_index do |op, _i|
        op.field_values.select { |fv| fv.field_type.sample? && (opts[:io] == 'all' || fv.role == opts[:io]) }.each do |input|
          items << input.child_item if input.child_item.location != 'deleted'
        end
      end

      if block_given?
        @protocol.release items.uniq, opts, &Proc.new
      else
        @protocol.release items.uniq, opts
      end

      self

    end

    def item_column(fv)
      fv.name + ' Item ID'
    end

    def collection_column(fv)
      fv.name + ' Collection ID'
    end

    def row_column(fv)
      fv.name + ' Row'
    end

    def column_column(fv)
      fv.name + ' Column'
    end

    def io_table(role = 'input')
      t = Table.new

      each_with_index do |op, _i|
        values = op.field_values.select { |fv| fv.role == role }
        values.each do |fv|
          if fv.part?
            unless t.has_column? fv.name
              t.column(fv.name,               fv.name)
               .column(collection_column(fv), collection_column(fv))
               .column(row_column(fv),        row_column(fv))
               .column(column_column(fv),     column_column(fv))
            end
            t.set(fv.name,               fv.child_sample ? fv.child_sample.name : 'NO SAMPLE')
             .set(collection_column(fv), fv.child_item_id || 'NO COLLECTION')
             .set(row_column(fv),        fv.row)
             .set(column_column(fv),     fv.column)
          elsif fv.value
            t.column(fv.name, fv.name)
            t.set(fv.name, fv.value)
          else
            unless t.has_column? fv.name
              t.column(fv.name,         fv.name)
               .column(item_column(fv), item_column(fv))
            end
            t.set(fv.name,         fv.child_sample ? fv.child_sample.name : 'NO SAMPLE')
             .set(item_column(fv), fv.child_item_id || 'NO ITEM')
          end
        end
        t.append
      end

      t
    end

    def add_static_inputs(name, sample_name, container_name)
      each do |op|
        sample = Sample.find_by_name(sample_name)
        container = ObjectType.find_by_name(container_name)
        op.add_input(name, sample, container)
        op.input(name).set item: sample.in(container.name).first
      end

      self
    end

  end
end
