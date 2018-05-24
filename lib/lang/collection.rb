module Lang

  class Scope

    def col_find c

      begin
        col = Item.find c
      rescue Exception => e
        raise "Could not find item #{c}."
      end

      if col.object_type.handler != "collection"
        raise "#{c} does not have the 'collection' handler."
      end

      begin
        data = JSON.parse(col.data, symbolize_names: true)
      rescue Exception => e
        raise "Could not parse JSON in collection #{c}."
      end

      [col, data[:matrix]]

     end

    def col_dimensions c

      c, m = col_find c

      [length(m), length(m[0])]

    end

    def col_get c, i, j

      if c.class != Fixnum || c.class != Fixnum || c.class != Fixnum
        raise "Invalid arguments to col_get(c,i,j). c should be an item id. i and j should be non-negative integers."
      end

      c, m = col_find c

      if 0 <= i && i < length(m)
        m[i][j]
      else
        nil
      end

    end

    def col_get_matrix c

      if c.class != Fixnum || c.class != Fixnum || c.class != Fixnum
        raise "Invalid arguments to col_get_matrix(c). c should be an item id."
      end

      c, mat = col_find c
      mat

    end

    def col_set c, i, j, val

      if c.class != Fixnum || c.class != Fixnum || c.class != Fixnum || val.class != Fixnum
        raise "Invalid arguments to col_set(c,i,j). c should be an item id. i and j should be non-negative integers. val should be a sample id."
      end

      c, mat = col_find c

      if 0 <= i && i < length(mat)
        mat[i][j] = val
      end

      c.data = { matrix: mat }.to_json
      c.save

      mat

    end

    def col_transfer sources, dests

      input = sources.collect { |c|
        c, mat = col_find c;
        { item: c, matrix: mat }
      }

      output = dests.collect { |c|
        c, mat = col_find c;
        { item: c, matrix: mat }
      }

      n = 0
      k = 0
      l = 0

      result = []

      begin # transfer samples ###############################
        (0..length(input) - 1).each do |m|
          (0..length(input[m][:matrix]) - 1).each do |i|
            (0..length(input[m][:matrix][i]) - 1).each do |j|

              puts "col_transfer working on #{[m, i, j]}"

              while output[n][:matrix][k][l] != -1

                l += 1

                if l >= length(output[n][:matrix][k])
                  l = 0
                  k += 1
                  if k >= length(output[n][:matrix])
                    l = 0
                    k = 0
                    n += 1
                    if n >= length(output)
                      raise "transfer complete"
                    end
                  end
                end

              end # while

              result.push [input[m][:item].id, i, j, output[n][:item].id, k, l]
              output[n][:matrix][k][l] = input[m][:matrix][i][j]

            end
          end
        end
      rescue Exception => e
        if e.to_s != "transfer complete"
          puts "Exception in col_transfer: " + e.to_s + e.backtrace.join("\n")
          raise "Exception in col_transfer: " + e.to_s
        else
          puts "Transfer complete"
        end
      end # begin #############################################

      output.each do |o|
        o[:item][:data] = ({ matrix: o[:matrix] }).to_json
        o[:item].save
      end

      return result

    end

    def col_new_matrix r, c

      Array.new(r, Array.new(c, -1))

    end

  end

end
