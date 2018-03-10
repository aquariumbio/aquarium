function equivalence_class_of(partition, field_value) {

  for(var i=0; i<partition.length; i++ ) {
    if ( aq.member(partition[i], field_value) ) {
      return partition[i]
    }
  }
  console.log("Could not find eq class of " + field_value.name + "(" + field_value.role + ")")
  return null;
}

function join(sets, partition_1, partition_2) {
  aq.remove(sets,partition_1);
  aq.remove(sets,partition_2);
  sets.push(partition_1.concat(partition_2));
  return sets
}

AQ.Plan.record_methods.field_values = function() {
  let plan = this,
      fvs = [];
  plan.operations.forEach(op => {
    fvs = fvs.concat(op.field_values);
  })
  return fvs;
}

AQ.Plan.record_methods.equiv = function(operation_1, field_value_1, operation_2, field_value_2) {

  let plan = this;

  if ( operation_1.rid == operation_2.rid &&
       field_value_1.field_type.routing == field_value_2.field_type.routing &&
       !field_value_1.field_type.array &&
       !field_value_2.field_type.array ) {
    return true;
  } else {

    for ( var i=0; i<plan.wires.length; i++ ) {
      let wire = plan.wires[i];
      if ( (wire.from == field_value_1 && wire.to == field_value_2) ||
           (wire.from == field_value_2 && wire.to == field_value_1) ) {
        return true
      } else {
      }

    }

  }

  return false;

}

AQ.Plan.record_methods.classes = function() {

  let plan = this,
      fvs = plan.field_values(),
      num = fvs.length,
      sets = aq.collect(fvs, fv => [fv] ),
      changed = true;

  while ( changed ) {
    changed = false
    plan.operations.forEach(operation_1 => {
      plan.operations.forEach(operation_2 => {
        operation_1.field_values.forEach(field_value_1 => {
          operation_2.field_values.forEach(field_value_2 => {
            if ( field_value_1 != field_value_2 ) {
              let class_1 = equivalence_class_of(sets, field_value_1);
              let class_2 = equivalence_class_of(sets, field_value_2);
              if ( plan.equiv(operation_1, field_value_1, operation_2, field_value_2 ) && 
                   class_1 && class_2 && class_1 != class_2 ) {
                sets = join(sets, class_1, class_2)
                changed = true;
              }              
            }
          })
        })
      });
    });
  } 

  return sets;

}

/**
* Assigns the given field value to the sample, and makes all other assignments
* that are implied by wires, routing, or inventory information.
* @method assign
* @param {FieldValue} field_value 
* @param {Sample} sample
* @return A promise that resolves once all implied assignments are made.
*/
AQ.Plan.record_methods.assign = function(field_value, sample) {

  let plan = this;
  plan.field_values().forEach(fv => fv.marked = false);
  plan.mark_leaves();
  plan.equivalences = plan.classes();

  return plan.assign_aux(field_value, sample);

}

AQ.Plan.record_methods.assign_aux = function(field_value, sample) {

  let plan = this, 
      promise = Promise.resolve();

  console.log(
    "assign_aux", 
    plan.parent_operation(field_value).operation_type.name + ", " +
    field_value.name + ": ",
    aq.collect(equivalence_class_of(plan.equivalences, field_value), e => e.name + "(" + e.role + ")").join(", ")
  )

  equivalence_class_of(plan.equivalences, field_value).forEach(other_field_value => {

    if ( !other_field_value.marked ) {
      other_field_value.marked = true;
      other_field_value.assign(sample);
      promise = promise.then(() => 
        plan.parent_operation(other_field_value)
            .new_instantiate(plan, other_field_value, sample.identifier))
    }

  });

  return promise.then(() => plan)

}

AQ.Operation.record_methods.new_instantiate = function(plan, field_value, sid) {

  let operation = this,
      promise = Promise.resolve();

  console.log("instantiating " + operation.operation_type.name + ", " + field_value.name + " with " + sid)

  promise = promise
    .then(() => AQ.Sample.find_by_identifier(sid))
    .then(sample => {

      let sub_promise = Promise.resolve();

      operation.field_values.forEach(operation_field_value => {

        // define routing
        if ( !operation_field_value.field_type.array && operation_field_value.routing == field_value.routing ) {
          operation.assign_sample(operation_field_value, sid);
        }

        // instantiate subsamples from sample inventory info
        sample.field_values.forEach(sample_field_value => { 
          if ( sample_field_value.name == operation_field_value.name && sample_field_value.child_sample_id ) {
            (function(ofv) {
              sub_promise = sub_promise
                .then(() => AQ.Sample.find(sample_field_value.child_sample_id))
                .then(child_sample => plan.assign_aux(ofv, child_sample))
            })(operation_field_value);
          } 
        })

      });

      return sub_promise;

    });

  return promise;

}

AQ.Plan.record_methods.mark_leaves = function()  {

  let plan = this;

  plan.operations.forEach(operation => {
    operation.outputs.forEach(o => o.leaf = false);
    operation.inputs.forEach(i => i.leaf = true);
  });

  plan.wires.forEach(wire => wire.to.leaf = false);

  return plan;

}
