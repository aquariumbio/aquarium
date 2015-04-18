module ApiCreate

  def create args

    case args[:model]

    when "sample"
      
      st = SampleType.find_by_name(args[:type])
      return error "Could not find sample type #{args[:type]}" unless st

      num_samples = Sample.where("created_at > ?", 1.day.ago).count
      max = Bioturk::Application.config.sample_creation_limit
      return error "Limit of #{max} new samples in 24 hours reached." if num_samples > max

      s = Sample.new({
        name: args[:name], 
        sample_type_id: st.id, 
        description: args[:description],
        user_id: user.id,
        project: args[:project]
      })

      if args[:fields]
        args[:fields].each do |name,val|
          s.set_property name.to_s, val
        end
      end

      if s.save
        add [ s ]
      else
        error s.errors.full_messages.join(', ')        
      end

    else

      warn "Creating at #{args[:model]} not implemented"

    end

  end

end