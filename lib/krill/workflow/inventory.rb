module Krill

  class Op

    def error ispec, msg
      ispec[:errors] ||= []
      ispec[:errors] << msg
    end

    def inventory
      Job.find(@jid).takes
    end

    private

    # The Sample object associated with the ispec
    def sample_aux ispec
      if ispec[:sample] && ispec[:sample].class == String
        s = Sample.find_by_id(ispec[:sample].as_sample_id)
        raise "No sample specified in #{ispec}." unless s
      else
        raise "Could not find Sample object for #{ispec} because 'sample' was not a string"
      end
      return s
    end

    # The list of Sample objects associated with the ispec
    def samples_aux ispec
      if ispec[:sample] && ispec[:sample].class == Array && ispec[:sample].conjoin { |s| s.class == String }
        a = ispec[:sample].collect { |s| s.as_sample_id }
        Sample.find(a).index_by(&:id).slice(*a).values
      else
        raise "Could not find Sample objects for #{ispec} because 'sample' was not an array of strings"        
      end
    end

    # The container object associated with the ispec
    def container_aux ispec
      if ispec[:container] && ispec[:container].class == String
        ObjectType.find(ispec[:container].as_container_id)
      else
        raise "Could not find ObjectType (aka Container) object for #{ispec} because 'container' was not a string"
      end
    end

    # The first Item in the database consistent with the ispec
    def first_item ispec

      s = sample_aux ispec
      if s
        i = (sample_aux ispec).items.select { |i| i.object_type_id == (container_aux ispec).id }
      else
        i = []
      end

      if i.length > 0 
        i.first
      else
        error ispec, "Could not find any items associated with this sample '#{ispec[:sample]}'."
        nil
      end

    end  

    # An array of the first Item in the database consistent with the list array of samples
    # and the container specified in the ispec
    def first_item_array ispec 

      (samples_aux ispec).collect do |s|
        i = s.items.select { |i| i.object_type_id == (container_aux ispec).id }
        if i.length > 0 
          i.first
        else
          error ispec, "Could not find any items associated with samples '#{ispec[:sample]}'."
          nil
        end
      end

    end    

  end

end
