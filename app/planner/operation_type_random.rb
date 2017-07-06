module OperationTypeRandom

  def routes

    field_types.collect { |ft| ft.routing }.uniq

  end

  def random n=1

    users = User.all.sample(n)

    (0..n-1).collect do |i|
      u = users[i] || users.sample
      op = operations.create(status: "pending", user_id: u.id)
      samples = {}

      field_types.each do |ft|

        if ft.ftype == 'sample'

          if samples[ft.routing]
            aft = ft.choose_aft_for(samples[ft.routing])
            op.set_property ft.name, samples[ft.routing], ft.role, false, aft
          else 
            random_sample, random_aft = ft.random
            op.set_property ft.name, random_sample, ft.role, false, random_aft
            Rails.logger.info "Error adding property: #{op.errors.full_messages.join(', ')}" unless op.errors.empty?
            samples[ft.routing] = random_sample
          end

        else

          if ft.choices != "" && ft.choices != nil
            op.set_property ft.name, ft.choices.split(',').sample, ft.role, true, nil
          elsif ft.type == "number"
            op.set_property ft.name, rand(100), ft.role, true, nil
          elsif ft.ftype == "json"
            op.set_property ft.name, "{ \"message\": \"random json parameters are hard to generate\" }", ft.role, true, nil            
          else
            op.set_property(ft.name, ["Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit" ].sample, ft.role, true, nil)
          end          

        end

      end
 
      op

    end

  end

end