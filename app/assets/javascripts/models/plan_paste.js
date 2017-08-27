AQ.Plan.record_methods.paste_plan = function (p) {

  var plan = this;

  plan.past_module(p);  
  aq.each(plan.operations, op => op.multiselect = false);
  aq.each(p.operations, op => plan.paste_operation(op));
  // plan.wires = plan.wires.concat(p.wires);

  aq.each(p.wires, w => {
    delete w.id;
    delete w.from_id;
    delete w.to_id;
    delete w.parent_id;
    plan.wires.push(w);
    console.log(w);
  });

  return plan;

}

AQ.Plan.record_methods.past_module = function(p) {

  var plan = this, 
      module_id_map;

  Module.id_map = [];

  p.base_module.renumber();
  aq.each(p.base_module.children, c => c.multiselect = true);
  plan.current_module.merge(p.base_module);

  Module.id_map[0] = plan.current_module.id;  

  aq.each(p.operations, op => {
    op.parent_id = Module.id_map[op.parent_id];
  });

}

AQ.Plan.record_methods.paste_operation = function(op) {

  var plan = this,
      new_op = op;

  delete new_op.id;
  new_op.multiselect = true;

  aq.each(new_op.field_values, fv => {
    delete fv.id;
    delete fv.parent_id;
    return fv;
  });

  new_op.recompute_getter("types_and_values");
  new_op.recompute_getter("inputs");
  new_op.recompute_getter("outputs");

  plan.operations.push(new_op);

  return plan;

}

