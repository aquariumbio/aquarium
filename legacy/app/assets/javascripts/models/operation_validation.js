/*
 * This method checks that an operation's information is consistent, all
 * routing and fields are consistent, etc.
 */

AQ.Operation.record_methods.valid = function() {
  let operation = this,
    valid = true;

  /*
   * Check that all field values that are defined have associated
   * routing defined.
   */

  operation.field_values.forEach(field_value => {
    if (!field_value.field_type.array && field_value.child_sample_id) {
      valid =
        valid && operation.routing[field_value.routing] == field_value.sid;
    }
  });

  return valid;
};

/*
 * Check that all operations are valid
 */
AQ.Plan.record_methods.check_operations = function() {
  let plan = this;
  plan.operations.forEach(operation => {
    if (!operation.valid()) {
      raise("Operation " + operation.id + " not valid.");
    }
  });
  return plan;
};
