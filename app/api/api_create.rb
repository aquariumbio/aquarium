module ApiCreate

  def create args

    case args[:model]

    when "sample"
      
      st = SampleType.find_by_name(args[:type])
      return error "Could not find sample type #{args[:type]}" unless st

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

    when "item"

      warn "Creating items not implemented"

    end

  end

end