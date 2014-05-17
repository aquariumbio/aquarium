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

        when Sample

          temp[:sample_type] = x.sample_type.attributes.symbolize_keys

        else

          puts "Not an item or a sample"

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

    def condition base, spec

      c = []

      spec.keys.each do |k|

        if spec[k].class == Hash
          c.push( condition "#{base}.#{k}", spec[k] )
        else # spec is number or string
          c.push "#{base}.#{k.to_s} == #{fix(spec[k])}"
        end

      end

      if c.length > 0
        c.join(' && ')
      else
        "true"
      end

    end

    def find name, spec

      # 
      # Define available tables. Note, no queries should be made at this point
      #
      tables = {
        item: Item.where("location != 'deleted'").includes(sample:[:sample_type]).includes(:object_type),
        sample: Sample.includes(:sample_type),
        sample_type: SampleType.includes(),
        object_type: ObjectType.includes(),
        task: Task.includes(:task_prototype)
      }

      puts(condition name.to_s, spec)

      #
      # Do the search
      #
      rows = tables[name].select do |x|
        begin
          r = eval(condition "x", spec)
        rescue 
          r = false # e.g. when item.sample == nil
        end
        r
      end

      rows.collect { |r| complete r }

    end

  end

end
