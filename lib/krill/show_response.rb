module Krill

  # @api krill
  require 'delegate'
  class ShowResponse < SimpleDelegator

    def helloworld
      "hello world"
    end
    
    # Return the response that was stored under `var`. When used with 
    # a key associated with a table response-set, returns a list of table responses
    # in order of the rows of the table.
    #
    # @param var [Symbol/String]  The var used to store data under
    #               specified in the get or select call of the ShowBlock
    def get_response var
      responses[var.to_sym]
    end

    # Returns data recorded in a specified row of an input table
    # @param var [Symbol/String]  the table key specified to store data under
    #               in the get.
    # @param opts [Hash]  additional options
    # @option op [Operation]  the Operation for which to retrieve the table data
    #               for, supposing the table was made on an OperationsList
    # @option row [Integer]  the row index of the table for which to retrieve table data
    # @return [String/Fixnum]  the data inputted in the particular input cell specified
    #               by the column associated with `var`, 
    #               and the row associated with either `op` or `row`   
    def get_table_response var, opts = {}
      if opts[:op] && opts[:row]
        raise "get_table_data called with Invalid parameters - specify op or row, not both"
      elsif self[:table_input].nil?
        return nil
      elsif opts[:op]
        opid = Operation.find(op).id # return op.id if passed an operation or the id itself
        return self[:table_input].find { |resp| resp[:key] == var.to_sym && resp[:opid] == opid }[:value]
      elsif opts[:row]
        return self[:table_input].find { |resp| resp[:key] == var.to_sym && resp[:row] == row }[:value]
      else # neither op nor row was specified. Return an array of data in the same order as input row
        return self[:table_input].sort { |resp| resp[:row] }.map { |resp| resp[:value] }
      end
    end

    def get_table_responses_column var
      self[:table_input].sort { |resp| resp[:row] }.map { |resp| resp[:value] } if self[:table_input]
    end

    # Returns a hash of user responses, each under the var name specified in the ShowBlock where 
    # the response was collected. Table responses are stored in this hash as a list in order of
    # the rows of the table.
    # @return [Hash]  the response hash with all user input
    def responses
      inline_responses = self.select { |key, value| key != :table_input && key != :timestamp }
      table_response_keys = self[:table_input].map { |ti| ti[:key] }.uniq
      table_responses = Hash.new
      table_response_keys.each do |key|
        table_responses[key] = get_table_responses_column(key)
      end

      inline_responses.merge(table_responses)
    end

    # Returns a Unix timestamp of the timepoint when the showblock associated with this ShowResponse
    # was seen and interacted with by the technician
    # @return [Integer]  Unix timestamp as seconds since 1970
    def timestamp
      self[:timestamp]
    end
  end
end