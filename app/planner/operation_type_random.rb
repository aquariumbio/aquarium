
module OperationTypeRandom
  def routes
    field_types.collect(&:routing).uniq
  end

  def random(n = 1)
    users = User.all.sample(n)

    (0..n - 1).collect do |i|
      u = users[i] || users.sample
      op = operations.create(status: 'pending', user_id: u.id)
      samples = {}

      field_types.each do |field_type|
        if field_type.ftype == 'sample'
          override_array = false
          if samples[field_type.routing]
            aft = field_type.choose_aft_for(samples[field_type.routing])
            field_sample = if !field_type.array
                             [samples[field_type.routing]].flatten.first
                           else
                             [samples[field_type.routing]] * 3
                           end
          else
            field_sample, aft = field_type.random
            samples[field_type.routing] = random_sample
          end
        else
          override_array = true
          aft = nil
          field_sample = if field_type.choices != '' && !field_type.choices.nil?
                           field_type.choices.split(',').sample
                         elsif field_type.type == 'number'
                           rand(100)
                         elsif field_type.ftype == 'json'
                           '{ "message": "random json parameters are hard to generate" }'
                         else
                           %w[Lorem ipsum dolor sit amet consectetur adipiscing elit].sample
                         end
        end
        op.set_property(field_type.name, field_sample, field_type.role, override_array, aft)
        Rails.logger.info("Error adding property: #{op.errors.full_messages.join(', ')}") unless op.errors.empty?
      end

      op
    end
  end
end
