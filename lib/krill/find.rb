module Krill

  module Base

    # @api private
    # This method is deprecated. Use ActiveRecord methods instead.
    def find(name, spec)

      if name == :project

        Sample.all.collect(&:project).uniq.sort

      else

        # Define available tables. Note, no queries should be made at this point
        tables = {
          item: Item.includes(sample: [:sample_type]).includes(:object_type),
          sample: Sample.includes(:sample_type),
          sample_type: SampleType.includes,
          object_type: ObjectType.includes,
          task: Task.includes(:task_prototype),
          group: Group.all,
          upload: Upload
        }

        # Do the search
        rows = tables[name].where(pluralize_table_names(spec))

        if name == :item
          return rows.reject(&:deleted?)
        else
          return rows
        end

      end

    end

    private

    def fix(val)

      if val.class == String
        "'#{val}'"
      else
        val
      end

    end

    def pluralize_table_names(spec)

      newspec = spec.clone

      reps =  { object_type: :object_types,
                sample: :samples,
                sample_type: :sample_types,
                task_prototype: :task_prototypes }

      spec.each do |k, v|
        if reps.key? k
          newspec.delete(k)
          newspec[reps[k]] = v
        end
      end

      newspec

    end

  end

end
