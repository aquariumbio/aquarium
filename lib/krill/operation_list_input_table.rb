module Krill

  module OperationList

    def custom_input key, opts={heading: "Custom Input", checkable: false, type: "string", style_block: nil}, &default_block
      self.each.with_index do |op, i|
        op.temporary[:uid] = i
      end
      temp_op = self.first
      default_values = self.map do |op|
        # d = op.temporary[key] # Prefer to default to last inputted value
        d ||= default_block.call(op)
      end
      @table.add_column opts[:heading], self.zip(default_values).map {|op, d|
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
      }
      self
    end

    # Collects inputs from custom_input and saves in operation.temporary hash
    # Needs operations due to the way Krill saves inputs to virtual operations
    def cleanup_input_table operations
      temp_op ||= self.first
      boolean_keys = temp_op.temporary.delete(:boolean_keys)
      boolean_blocks = temp_op.temporary.delete(:boolean_blocks)
      messages = []

      self.each do |op|
        vhash = op.temporary[:validation]
        op.temporary[:temporary_keys].each do |temp_key|
          # Parse key
          uid, key = temp_key.to_s.split('__')
          key = key.to_sym
          temp_op = operations.select {|op| op.temporary.keys.include? temp_key}.first
          val = temp_op.temporary[temp_key]

          # Input validation
          vblock = vhash[key] if vhash
          valid = true

          valid = vblock.call(op, val) if vblock
          if not valid
            msghash = op.temporary[:validation_messages] || Hash.new
            msgblock = msghash[key]
            validation_message = msgblock.call(op, key, val) if msgblock
            validation_message ||= "Input invalid: operation_id: #{op.id}, key: #{key}, value: #{val}"
            messages << validation_message
          end

          op.temporary[key.to_sym] = val
          temp_op.temporary.delete(temp_key)
        end

        boolean_keys.each do |key|
          b = boolean_blocks[key]
          v = op.temporary.delete(key)
          k, _ = key.to_s.split("||").map(&:to_sym)
          op.temporary[k] = b.call(v)
        end if boolean_keys

        op.temporary.delete(:temporary_keys)
        op.temporary.delete(:uid)
        op.temporary.delete(:validation)
        op.temporary.delete(:validation_messages)
      end
      messages.uniq
    end


    # A custom selection input with input validation
    def custom_selection key, choices, options={}, &default_block
      opts = {heading: "Custom Selection", checkable: false, style_block: nil, type: "string"}
      opts.merge! options
      key = key.to_sym
      opts[:heading] += " (#{choices.join("/")})"
      self.custom_input(key, opts, &Proc.new)
      self.validate(key) {|op, v| choices.include?(v)}
      self.validation_message(key) {|op, k, v| "Choice #{v} is not valid. Please select from #{choices}"}
    end

    # A custom "yes" or "no" input box. Gets converted to true or false in cleanup_input_table
    def custom_boolean key, options={}, &default_block
      opts = {heading: "Custom Boolean", checkable: false, style_block: nil}
      opts.merge! options
      choices ||= ["y", "n"]
      key = "#{key}||boolean".to_sym
      key = key.to_sym


      # Default boolean block
      boolean_block ||= Proc.new {|x|
        choices[0] == x.downcase[0]
      }

      # Designate which keys are boolean keys
      temp_op = self.first
      temp_op.temporary[:boolean_keys] ||= []
      temp_op.temporary[:boolean_keys] << key

      # Determine how to interpret input values as booleans
      temp_op.temporary[:boolean_blocks] ||= Hash.new
      temp_op.temporary[:boolean_blocks][key] = boolean_block

      opts[:type] = "string"
      self.custom_selection(key, choices, opts, &Proc.new)
      self.validate(key) {|op, v| choices.include?(v.downcase[0])} # override the validation
    end

    def custom_input key, options={}, &default_block
      opts = {heading: "Custom Input", checkable: false, type: "string", style_block: nil, default_to_previous: true}
      opts.merge! options
      self.each.with_index do |op, i|
        op.temporary[:uid] = i
      end
      temp_op = self.first
      default_values = self.map do |op|
        d = op.temporary[key] if opts[:default_to_previous] # Prefer to default to last inputted value
        d ||= default_block.call(op)
      end
      @table.add_column opts[:heading], self.zip(default_values).map {|op, d|
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
      }
      self
    end

    # Tags an input key for validation, by calling a validation
    # block for each operation
    #
    # ==== Example (validate :some_key to have input value between 1 and 10)
    # operations.start_table
    #   .custom_input(:some_key, heading: "Input", type: "number") { |op| 1 }
    #   .validate(:some_key) { |op, inputted_value| inputted_value.between?(1,10) }
    #   .end_Table
    def validate key, &validation_block
      self.each do |op|
        validation = op.temporary[:validation] || Hash.new
        validation[key] = validation_block
        op.temporary[:validation] = validation
      end
      self
    end

    # Sends message for valid and invalid inputs based on validation
    #
    # ==== Example (validate :some_key to have input value between 1 and 10)
    # operations.start_table
    #   .custom_input(:some_key, heading: "Input", type: "number") { |op| 1 }
    #   .validate(:some_key) { |op, inputted_value| inputted_value.between?(1,10) }
    #   .validation_message(:some_key) { |op, key, val|
    #     "Operation id #{op.id} with key #{key} had incorrect value #{val}" + \
    #     "Value should be between 1 and 10."
    #     }
    #   .end_Table
    def validation_message key, &message_block
      self.each do |op|
        message_hash = op.temporary[:validation_messages] || Hash.new
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
      self.first.temporary[_create_temp_key(key, op)]
    end

  end

  module Base
    # Create a Proc that details how to create the table
    # Pass in operations (virtual or non-virtual)
    # Pass optional block with additional instructions
    def show_with_input_table ops, create_block, num_tries=5
      ops.extend(OperationList)
      counter = 0
      results = nil
      continue = true
      msgs = []
      while continue and counter < num_tries
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

        msgs = ops.cleanup_input_table operations
        if msgs.any?
          continue = true
        else
          continue = false
        end
      end
      results
    end
  end

end
