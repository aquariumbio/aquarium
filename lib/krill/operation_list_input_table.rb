# frozen_string_literal: true

module Krill

  module OperationList

    # Appends a column to an OperationsList table which accepts user input. Used in conjunction with show_with_input_table.
    # Consider using `get` instead, unless you have a specific reason to use this method
    def custom_input(key, opts = { heading: 'Custom Input', checkable: false, type: 'string', style_block: nil }, &default_block)
      each.with_index do |op, i|
        op.temporary[:uid] = i
      end
      temp_op = first
      default_values = map do |op|
        default_block.call(op)
      end
      entries = zip(default_values).map do |op, d|
        # Save a list of temporary keys to be deleted later
        new_key = _create_temp_key(key, op)
        temporary_keys = op.temporary[:temporary_keys] || []
        temporary_keys.push(new_key)
        op.temporary[:temporary_keys] = temporary_keys
        o = {
          type: opts[:type],
          operation_id: temp_op.id,
          key: new_key,
          default: d
        }
        style = opts[:style_block].call(op) if opts[:style_block]
        o.merge!(style) if style
        o
      end
      @table.add_column(opts[:heading], entries)

      self
    end

    # Collects inputs from custom_input and saves in operation.temporary hash
    def cleanup_input_table
      temp_op = first
      messages = []
      each do |op|
        vhash = op.temporary[:validation]
        op.temporary[:temporary_keys].each do |temp_key|
          # Parse key
          _uid, key = temp_key.to_s.split('__')
          key = key.to_sym
          val = temp_op.temporary[temp_key]

          # Input validation
          vblock = vhash[key] if vhash
          valid = true
          valid = vblock.call(op, val) if vblock
          unless valid
            msghash = op.temporary[:validation_messages] || {}
            msgblock = msghash[key]
            validation_message = msgblock.call(op, key, val) if msgblock
            validation_message ||= "Input invalid: operation_id: #{op.id}, key: #{key}, value: #{val}"
            messages << validation_message
          end

          op.temporary[key.to_sym] = val
          temp_op.temporary.delete(temp_key)
        end
        op.temporary.delete(:temporary_keys)
        op.temporary.delete(:uid)
        op.temporary.delete(:validation)
        op.temporary.delete(:validation_messages)
      end
      messages
    end

    # Tags an input key for validation, by calling a validation
    # block for each operation
    #
    # @example (validate :some_key to have input value between 1 and 10)
    #   operations.start_table
    #     .custom_input(:some_key, heading: "Input", type: "number") { |op| 1 }
    #     .validate(:some_key) { |op, inputted_value| inputted_value.between?(1,10) }
    #     .end_Table
    def validate(key, &validation_block)
      each do |op|
        validation = op.temporary[:validation] || {}
        validation[key] = validation_block
        op.temporary[:validation] = validation
      end
      self
    end

    # Sends message for valid and invalid inputs based on validation
    #
    # @example (validate :some_key to have input value between 1 and 10)
    #   operations.start_table
    #     .custom_input(:some_key, heading: "Input", type: "number") { |op| 1 }
    #     .validate(:some_key) { |op, inputted_value| inputted_value.between?(1,10) }
    #     .validation_message(:some_key) { |op, key, val|
    #       "Operation id #{op.id} with key #{key} had incorrect value #{val}" + \
    #       "Value should be between 1 and 10."
    #       }
    #     .end_Table
    def validation_message(key, &message_block)
      each do |op|
        message_hash = op.temporary[:validation_messages] || {}
        message_hash[key] = message_block
        op.temporary[:validation_messages] = message_hash
      end
      self
    end

    private

    def _create_temp_key(key, op)
      "#{op.temporary[:uid]}__#{key}".to_sym
    end

    def _get_custom_input(key, op)
      first.temporary[_create_temp_key(key, op)]
    end

  end

  module Base
    # Create a Proc that details how to create the table
    # Pass in operations (virtual or non-virtual)
    # Pass optional block with additional instructions
    def show_with_input_table(ops, create_block, num_tries = 5)
      ops.extend(OperationList)
      counter = 0
      results = nil
      continue = true
      msgs = []
      while continue && (counter < num_tries)
        counter += 1
        input_table = create_block.call(ops)
        extra = ShowBlock.new(self).run(&Proc.new) if block_given?

        results = show do
          raw extra if block_given?
          if msgs.any?
            msgs.each do |m|
              warning m
            end
          end
          table input_table.render
        end

        msgs = ops.cleanup_input_table
        continue = if msgs.any?
                     true
                   else
                     false
                   end
      end
      results
    end
  end

end
