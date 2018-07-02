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

    # TODO MODIFY FRONTEND TO RETURN THE ROW INDEX OF TABLE INPUTS ALONG WITH EVERYTHING ELSE
    # CURRENTLY, ROW OF TABLE IS NOT KEPT TRACK OF BY :table_inputs. 

    # The alternative is to complicate an existing hash var like opid or key with this information. 
    # Not an ideal workaround for operationslist tables, since it breaks backwards compatibility, but
    # it would work fine for the tables that can -only- be accessed by row anyway.
    # Adding a complicated hash var only for standalone tables would also mean that standalone tables would
    # work as a special case in get_table_response

    # Another alternative is to change the interface of ShowResponse to ignore rows, and change the
    # interface of add_response_column to accept a list of uniq keys rather than using one key for the whole column

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
    #               returns nil if the requested row/column pair doesn't exist
    def get_table_response var, opts = {}
      if (opts[:op] && opts[:row]) || (!opts[:op] && !opts[:row])
        raise "get_table_data called with Invalid parameters - specify one of op or row, not both"
      elsif self[:table_inputs].nil?
        return nil
      elsif opts[:op]
        opid = Operation.find(opts[:op]).id # return op.id if passed an operation or the id itself
        target_table_input = self[:table_inputs].find { |ti| (ti[:key] == var) && (ti[:opid] == opid) }
      elsif opts[:row]
        target_table_input = self[:table_inputs].find { |ti| (ti[:key] == var) && (ti[:row] == opts[:row]) }
      end
      return target_table_input[:value] if target_table_input
    end

    def get_table_responses_column var
      self[:table_inputs].select { |ti| ti[:key] == var }.sort { |ti| ti[:row] }.map { |ti| ti[:value] } if self[:table_inputs]
    end

    # Returns a hash of user responses, each under the var name specified in the ShowBlock where 
    # the response was collected. Table responses are stored in this hash as a list in order of
    # the rows of the table.
    # @return [Hash]  the response hash with all user input
    def responses
      inline_responses = self.select { |key, value| key != :table_inputs && key != :timestamp }
      table_response_keys = self[:table_inputs] ? self[:table_inputs].map { |ti| ti[:key] }.uniq : []
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