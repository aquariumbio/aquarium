AQ.Plan.record_methods.paste_plan = function (p) {

  var plan = this;

  plan.clear_paste_map();
  aq.each(plan.operations, op => op.multiselect = false);
  aq.each(p.operations, op => plan.paste_operation(op));
  aq.each(p.wires, w => plan.paste_wire(w));
  delete plan.paste_map;

  return plan;

}

AQ.Plan.record_methods.clear_paste_map = function () {

  var plan = this;

  plan.paste_map = {
    operations: [],    
    field_values: []
  }

  return plan;

}

AQ.Plan.record_methods.paste_operation = function(op) {

  var plan = this,
      new_op = AQ.Operation.record(op);

  delete new_op.id;
  delete new_op.field_values;
  new_op.multiselect = true;

  plan.paste_map.operations[op.rid] = new_op;

  new_op.field_values = aq.collect(op.field_values, fv => {
    var new_fv = AQ.FieldValue.record(fv);
    delete new_fv.id;
    delete new_fv.parent_id;
    plan.paste_map.field_values[fv.rid] = new_fv;
    return new_fv;
  });

  new_op.recompute_getter("types_and_values");
  new_op.recompute_getter("inputs");
  // new_op.recompute_getter("outputs");

  plan.operations.push(new_op);

  return plan;

}

AQ.Plan.record_methods.paste_wire = function(wire) {

  var plan = this,
      new_wire;

  new_wire = AQ.Wire.record({
    to_op: plan.paste_map.operations[wire.to_op.rid],
    to: plan.paste_map.field_values[wire.to.rid],
    from_op: plan.paste_map.operations[wire.from_op.rid],
    from: plan.paste_map.field_values[wire.from.rid]
  });

  plan.wires.push(new_wire);

  return plan;

}
