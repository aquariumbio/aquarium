class SampleTree

  def initialize sid
    @sample = Sample
              .includes(:sample_type)
              .find(sid)
    @parents = []
  end

  def parents
    parents = @sample
              .properties
              .select { |_k, v| v.class == Sample }
              .each_with_object({}) { |(k, sample), h| h[k] = SampleTree.new sample }
  end

  def expand
    @parents = parents
    self
  end

  def as_json

    samp = @sample.as_json(:include => [
                             :sample_type,
                             :items => { :include => :object_type }
                           ])

    samp[:user_login] = @sample.user.login

    samp[:items].each do |i|
      begin
        i['data'] = JSON.parse i['data']
        if i['data']['from']
          if i['data']['from'].class == String
            i['data']['from'] = [Item.find_by_id(i['data']['from']).as_json(:include => :object_type)]
          else
            i['data']['from'] = i['data']['from'].collect { |id|
              Item.find_by_id(id).as_json(:include => :object_type)
            }
          end
        end
      rescue
        i['data'] = {}
      end
    end

    {
      sample: samp,
      parents: @parents.collect { |p| p.as_json }
    }

  end

end
