module Lang

  class Scope

    def complete x

      temp = x.attributes.symbolize_keys

      case x

      when Item

        if x.sample_id
          temp[:sample] = x.sample.attributes.symbolize_keys
          temp[:sample][:sample_type] = x.sample.sample_type.attributes.symbolize_keys
        end

        if x.object_type
          temp[:object_type] = x.object_type.attributes.symbolize_keys
        end

        begin
          temp[:data] = JSON.parse(temp[:data], symbolize_names: true)
        rescue
          temp[:data] = { error: "Could not parse data field" }
        end

      when Sample

        temp[:sample_type] = x.sample_type.attributes.symbolize_keys

      when Task

        temp[:task_prototype] = x.task_prototype.attributes.symbolize_keys
        temp[:specification] = JSON.parse(temp[:specification], symbolize_names: true)
        temp[:task_prototype][:prototype] = JSON.parse(temp[:task_prototype][:prototype], symbolize_names: true)

      end

      temp

    end

    def fix val

      if val.class == String
        "'#{val}'"
      else
        val
      end

    end

    def pluralize_table_names spec

      newspec = spec.clone

      reps =  { object_type: :object_types,
                sample: :samples,
                sample_type: :sample_types,
                task_prototype: :task_prototypes }

      spec.each do |k, v|
        if reps.has_key? k
          newspec.delete(k)
          newspec[reps[k]] = v
        end
      end

      newspec

    end

    def find name, spec

      #
      # Define available tables. Note, no queries should be made at this point
      #
      tables = {
        item: Item.includes(sample: [:sample_type]).includes(:object_type).where("location != 'deleted'"),
        sample: Sample.includes(:sample_type),
        sample_type: SampleType.includes(),
        object_type: ObjectType.includes(),
        task: Task.includes(:task_prototype)
      }

      #
      # Do the search
      #
      rows = tables[name].where(pluralize_table_names(spec))

      rows.collect { |r| complete r }

    end

  end

end
