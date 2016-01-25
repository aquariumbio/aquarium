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
      .select { |k,v| v.class == Sample }
      .each_with_object({}) { |(k,sample),h| h[k] = SampleTree.new sample }
  end

  def expand
    @parents = parents
    self
  end

  def as_json 

    samp = @sample.as_json(:include => [
      :sample_type,      
      :items => { :include => :object_type }])

    samp[:user_login] = @sample.user.login

    samp[:items].each do |i|
      Rails.logger.info "#{i}: #{i.class}, #{i.keys}, _#{i['data']}_, _#{i[:data]}_"
      begin
        i['data'] = JSON.parse i['data']
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