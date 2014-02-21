module Lang

  class Scope 

    def collection spec

      if spec.class == Hash

        s = {
          name: "Unknown", 
          description: "No description provided", 
          object_type: "Generic Collection", 
          part_object_type: "Generic Part",
          rows: 1, 
          columns: 1, 
          project: "Unknown",
          location: "Bench" }.merge spec

        collection_ot = ObjectType.find_by_name(s[:object_type])
        part_ot = ObjectType.find_by_name(s[:part_object_type])

        if !collection_ot
          raise "Could not find object type #{s[:object_type]} when attempt to make new collection."
        end

        if !part_ot
          raise "Could not find object type #{s[:part_object_type]} when attempt to make new collection."
        end

        c = Collection.new
        c.name = s[:name]
        c.object_type_id = part_ot.id
        c.rows = s[:rows]
        c.columns = s[:columns]
        c.project = s[:project]
        c.description = s[:description]
        c.save

        i = Item.new
        i.object_type_id = collection_ot.id
        i.location = s[:location]
        i.quantity = 1
        i.inuse = 1
        i.collection_id = c.id
        i.save

        { id: i.id, name: i.object_type.name, data: "" }

      else
        raise "Invalid argument to collection. Expecting a hash with fields name, part_type, rows, cols, and project."
      end

    end

  end

end
