module Krill

  class Op

    def error ispec, msg
      ispec[:errors] ||= []
      ispec[:errors] << msg
    end

    private

    # The Sample object associated with the ispec
    def sample ispec
      if ispec[:sample] && ispec[:sample].class == String
        Sample.find(ispec[:sample].as_sample_id)
      else
        raise "Could not find Sample object for #{ispec} because 'sample' was not a string"
      end
    end

    # The list of Sample objects associated with the ispec
    def samples ispec
      if ispec[:sample] && ispec[:sample].class == Array && ispec[:sample].conjoin { |s| s.class == String }
        Sample.find(ispec[:sample].collect { |s| s.as_sample_id })
      else
        raise "Could not find Sample objects for #{ispec} because 'sample' was not an array of strings"        
      end
    end

    # The container object associated with the ispec
    def container ispec
      if ispec[:container] && ispec[:container].class == String
        ObjectType.find(ispec[:container].as_container_id)
      else
        raise "Could not find ObjectType (aka Container) object for #{ispec} because 'container' was not a string"
      end
    end

    # The first Item in the database consistent with the ispec
    def first_item ispec

      i = (sample ispec).items.select { |i| i.object_type_id == (container ispec).id }

      if i.length > 0 
        i.first
      else
        error ispec, "Could not find any items associated with this sample 'ispec[:sample]'."
        nil
      end

    end  

    # An array of the first Item in the database consistent with the list array of samples
    # and the container specified in the ispec
    def first_item_array ispec 

      (samples ispec).collect do |s|
        i = s.items.select { |i| i.object_type_id == (container ispec).id }
        if i.length > 0 
          i.first
        else
          error ispec, "Could not find any items associated with sample 'ispec[:sample]'."
          nil
        end
      end

    end    

  end

end
