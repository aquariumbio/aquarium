module OperationTypeRandom

  def routes

    field_types.collect { |ft| ft.routing }.uniq

  end

  def random n=1

    users = User.all.sample(n)

    (0..n-1).collect do |i|

      op = operations.create(status: "pending", user_id: users[i].id)
      samples = {}

      field_types.each do |ft|

        if samples[ft.routing]
          aft = ft.choose_aft_for(samples[ft.routing])
          op.set_property ft.name, samples[ft.routing], ft.role, false, aft
        else
          random_sample, random_aft = ft.random
          op.set_property ft.name, random_sample, ft.role, false, random_aft         
          samples[ft.routing] = random_sample
        end

      end
 
      op

    end

  end

end