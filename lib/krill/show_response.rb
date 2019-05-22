# frozen_string_literal: true

module Krill

  require 'delegate'

  # @api krill
  # Defines a wrapper for the data hash that is returned by the `show` method, with
  # a simplified interface, additional convenience methods,
  # and abstraction of implementation details. This is a decorator class to be instantiated
  # with a Hash.
  # Initialized with a Hash, which has a :timepoint value as a float, and
  # a :table_inputs value as an array of hashes in the format expected from `show` return
  #
  class ShowResponse < SimpleDelegator

    # Return the response that was stored under `var`. When used with
    #
    # a key associated with a table response-set, returns a list of table responses
    # in order of the rows of the table.
    #
    # @param var [Symbol/String]  The var used to store data under
    #               specified in the get or select call of the ShowBlock
    def get_response(var)
      responses[var.to_sym]
    end

    # Returns data recorded in a specified row of an input table
    #
    # @param var [Symbol/String]  the table key that was specified to store data under
    #               in the `get`.
    # @param opts [Hash]  additional options
    # @option op [Operation]  the Operation for which to retrieve the table data
    #               for, supposing the table was made on an OperationsList
    # @option row [Integer]  the row index of the table for which to retrieve table data
    # @return [String/Fixnum]  the data inputted in the particular input cell specified
    #               by the column associated with `var`,
    #               and the row associated with either `op` or `row`
    #               returns nil if the requested row/column pair doesn't exist
    def get_table_response(var, opts = {})
      raise TableCellUndefined, 'Invalid parameters for get_table_response - specify one of op or row, not both' if (opts[:op] && opts[:row]) || (!opts[:op] && !opts[:row])
      return nil if self[:table_inputs].nil?

      target_table = self[:table_inputs].select { |ti| (ti[:key].to_sym == var.to_sym) }
      return nil if target_table.empty?

      if opts[:op]
        raise TableCellUndefined, "Invalid parameters for get_table_response - an :op option cannot be specified for a table that doesn't have operations corresponding to its rows" if target_table.first[:opid] < 0

        opid = Operation.find(opts[:op]).id # return op.id if passed an operation or the id itself
        target_input_cell = target_table.find { |ti| ti[:opid] == opid }
      elsif opts[:row]
        target_input_cell = target_table.find { |ti| ti[:row] == opts[:row] }
      end
      raise TableCellUndefined if target_input_cell.nil?

      (target_input_cell[:type] == 'number' ? target_input_cell[:value].to_f : target_input_cell[:value])
    end

    # Returns a hash of user responses, each under the var name specified in the ShowBlock where
    # the response was collected. Table responses are stored in this hash as a list in order of
    # the rows of the table.
    #
    # @return [Hash]  the response hash with all user input
    def responses
      inline_responses = select { |key, value| key != :table_inputs && key != :timestamp && !is_upload?(key) }

      upload_response_keys = select { |key, value| is_upload?(key) }.keys
      upload_responses = {}
      upload_response_keys.each do |key|
        upload_responses[key] = get_upload_response(key)
      end

      table_response_keys = self[:table_inputs] ? self[:table_inputs].map { |ti| ti[:key] }.uniq : []
      table_responses = {}
      table_response_keys.each do |key|
        table_responses[key.to_sym] = get_table_responses_column(key)
      end

      inline_responses.merge(table_responses).merge(upload_responses)
    end

    # Returns a Unix timestamp of the timepoint when the showblock associated with this ShowResponse
    # was seen and interacted with by the technician
    #
    # @return [Integer]  Unix timestamp as seconds since 1970
    def timestamp
      self[:timestamp]
    end

    private

    def get_table_responses_column(var)
      self[:table_inputs].select { |ti| ti[:key].to_sym == var.to_sym }.sort_by { |a| a[:row] }.map { |ti| ti[:type] == 'number' ? ti[:value].to_f : ti[:value] } if self[:table_inputs]
    end

    # Checks to see if a given key corresponds to a list of upload objects
    #
    # @param var [Symbol/String]  the key that was specified to store data under in the `upload` call
    # @return [Boolean]  true if the key corresponds to a list of upload objects
    def is_upload?(var)
      self[var.to_sym].is_a?(Array) && self[var.to_sym].all? { |up_hash| up_hash.is_a?(Hash) && up_hash.key?(:name) && up_hash.key?(:name) }
    end

    # Returns a list of the Upload objects created from files uploaded in the ShowBlock
    #
    # @param var [Symbol/String]  the key that was specified to store data under in the `upload` call
    # @return [Array<Upload>]  list of the Upload objects corresponding to the given key, or nil if the key
    #               doesn't correspond to a valid list of uploads
    def get_upload_response(var)
      return nil unless is_upload?(var)

      Upload.find(self[var.to_sym].map { |up_hash| up_hash[:id] })
    end
  end

  class TableCellUndefined < StandardError
    def initialize(msg = 'A table cell was picked out that is out of bounds or cannot exist')
      super
    end
  end
end
