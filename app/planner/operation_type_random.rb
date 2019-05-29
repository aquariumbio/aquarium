# frozen_string_literal: true

module OperationTypeRandom
  def routes
    field_types.collect(&:routing).uniq
  end

  # TODO: this should act on operations and not operation type
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
            # TODO: make this do something
          else
            field_sample, aft = field_type.random
            samples[field_type.routing] = random_sample
          end
          # TODO: what is supposed to happen here?
        elsif ft.choices != '' && !ft.choices.nil?
          op.set_property(ft.name, ft.choices.split(',').sample, ft.role, true, nil)
        elsif ft.type == 'number'
          op.set_property(ft.name, rand(100), ft.role, true, nil)
        elsif ft.ftype == 'json'
          op.set_property(ft.name, '{ "message": "random json parameters are hard to generate" }', ft.role, true, nil)
        else
          op.set_property(ft.name, %w[Lorem ipsum dolor sit amet consectetur adipiscing elit].sample, ft.role, true, nil)
        end
      end

      op
    end
  end
end
