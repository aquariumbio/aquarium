class Protocol

  def main

    output_collections = {}

    operations.each_with_index do |op,i|

      op.inputs.each do |input|
        input.retrieve
      end

      op.outputs.each do |output|

        if output.part?
          output_collections[output.name] ||= output.make_collection(operations.count, 1)
          output.make_part(output_collections[output.name],i,0)
        else
          output.make
        end

      end

    end

    ids = operations.collect { |op| op.id }

    show do
      title "Operations"
      note ids
    end

    return {}  

  end

end
