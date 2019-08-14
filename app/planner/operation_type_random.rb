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
        if field_type.sample?
          if samples[field_type.routing]
            aft = field_type.choose_aft_for(samples[field_type.routing])
            field_sample = if !field_type.array
                             [samples[field_type.routing]].flatten.first
                           else
                             [samples[field_type.routing]] * ((rand() * 10).floor + 1)
                           end
          else
            field_sample, aft = field_type.random

            samples[field_type.routing] = field_sample
          end
          op.set_property(field_type.name, field_sample, field_type.role, false, aft)
          Rails.logger.info "Error adding property: #{op.errors.full_messages.join(', ')}" unless op.errors.empty?
        elsif field_type.choices != '' && !field_type.choices.nil?
          op.set_property(field_type.name, field_type.choices.split(',').sample, field_type.role, true, nil)
        elsif field_type.number?
          op.set_property(field_type.name, rand(100), field_type.role, true, nil)
        elsif field_type.json?
          op.set_property(field_type.name, '{ "message": "random json parameters are hard to generate" }', field_type.role, true, nil)
        else
          op.set_property(field_type.name, %w[Lorem ipsum dolor sit amet consectetur adipiscing elit].sample, field_type.role, true, nil)
        end
      end

      op
    end
  end
end
