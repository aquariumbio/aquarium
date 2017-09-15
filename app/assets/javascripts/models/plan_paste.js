AQ.Plan.record_methods.paste_plan = function (p,offset) {

  var plan = this;

  plan.paste_module(p,offset);  

  aq.each(plan.operations, op => op.multiselect = false);
  aq.each(p.operations, op => { 
    plan.paste_operation(op, offset)
  });

  aq.each(p.wires, w => {
    delete w.id;
    delete w.from_id;
    delete w.to_id;
    delete w.parent_id;
    plan.wires.push(w);
  });

  return plan;

}

AQ.Plan.record_methods.paste_module = function(p,offset) {

  var plan = this, 
      module_id_map;

  Module.id_map = [];

  p.base_module.renumber();
  aq.each(p.base_module.children, c => {
    c.x += offset;
    c.y += offset;
  });
  aq.each(p.base_module.children, c => c.multiselect = true);
  plan.current_module.merge(p.base_module);

  Module.id_map[0] = plan.current_module.id;  

  aq.each(p.operations, op => {
    op.parent_id = Module.id_map[op.parent_id];
  });

}

AQ.Plan.record_methods.paste_operation = function(op, offset) {

  var plan = this,
      new_op = op;

  delete new_op.id;
  new_op.multiselect = true;

  if ( new_op.parent_id == 0 ) {
    new_op.x += offset;
    new_op.y += offset;  
  }

  aq.each(new_op.field_values, fv => {
    delete fv.child_item_id;
    delete fv.row;
    delete fv.column
    delete fv.id;
    delete fv.parent_id;
    fv.recompute_getter("items");
    return fv;
  });

  new_op.recompute_getter("types_and_values");
  new_op.recompute_getter("inputs");

  plan.operations.push(new_op);

  return plan;

}
