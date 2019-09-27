# frozen_string_literal: true

module FieldTypePlanner

  def random
    [nil, nil] if allowable_field_types.empty?

    aft = allowable_field_types.sample
    if array
      return [[nil, nil, nil], aft] unless aft.sample_type

      return [aft.sample_type.samples.sample(3), aft]
    end
    return [nil, aft] unless aft.sample_type
    # TODO: this should raise named exception class
    raise "There are no samples of type #{aft.sample_type.name}" if aft.sample_type.samples.empty?

    [aft.sample_type.samples.sample, aft]
  end

  def choose_aft_for(sample)
    types = allowable_field_types.select do |type|
      type.sample_type_id == sample.sample_type.id
    rescue StandardError
      true
    end

    types.sample unless types.empty?
  end

end
