#
# SV := {
#   field_name: CONSTRAINTS | SV
#   ...
# }
#
# CONSTRAINTS := { CONSTRAINTS, ... } | CONSTRAINT
#
# CONSTRAINT := ATOMIC | OP
#
# OP := op: or | op: and
#
# ATOMIC_CONSTRAINT := present:boolean | valid_choice:boolean | length: { min:integer, max:integer }, etc
#
# TODO: Need logical operators (e.g. primer stock OR primer aliquot in inventory)
#       Should you be able to check the sample type? Sure, why not?
#
# EXAMPLES: { "Forward Primer" => { inventory: [ { name: "Primer Stock", min: 1 }, { name: "Primer Aliquot", min: 1 } ] } } }
#           { "SampleType": "Fragment" }
#

module SampleValidator

  ###########################################################################################
  # Constraint Specific Methods
  #

  def validate_constraint_present ft, val
    v = value ft
    if val && !v
      validation_error "Field #{ft.name} is not present"
    elsif !val && v
      validation_error "Field #{ft.name} is present"
    else
      true
    end
  end

  ###########################################################################################
  # Logic
  #

  def validate_constraint_or ft, constraints

    if !constraints || constraints.class != Array
      validation_error "Or does not apply to a list of constraints."
    else
      puts "Checking #{constraints}"
      constraints.each do |c|
        puts "Checking #{c}"
        return true if validate_aux ft, c
        puts "  ... False"
      end
      return validation_error "Or: #{constraints.to_s} not satisfied"
    end

  end

  ###########################################################################################
  # Base Validator Methods
  #

  def validation_error msg
    @validation_errors << msg
    false
  end

  def validate_aux ft, c
    if ft.type == 'sample'
      child_sample.validate c
    else
      results = c.collect do |type, val|
        self.method("validate_constraint_#{type}").call(ft, val)
      end
      results.inject { |prod, x| prod && x }
    end
  end

  def validate sv

    @validation_errors ||= []
    is_valid = true

    sv.each do |key, c|
      ft = field_type(key)
      if ft
        is_valid = is_valid && validate_aux(ft, c)
      else
        is_valid = validation_error "Field '#{key}' not found"
      end
    end

    @validation_errors.each do |e|
      self.errors.add :validate, e
    end

    return is_valid

  end

end
