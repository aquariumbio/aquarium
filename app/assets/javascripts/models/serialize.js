AQ.Plan.record_methods.serialize = function() {

  var plan = this, ops;

  p = {
    id: plan.id,
    operations: aq.collect(plan.operations, op => op.serialize() ),
    wires: aq.collect(plan.wires, w => w.serialize() ),
    user_budget_association: plan.uba,
    status: plan.status,
    cost_limit: plan.cost_limit,
    name: plan.name,
    rid: plan.rid,
    layout: plan.serialize_module(plan.base_module)
  }

  return p;

}

AQ.Plan.record_methods.serialize_module = function(m) {

  var plan = this,
      props = [ "id", "parent_id", "name", "x", "y", "width", "height", "model", "input", "output", "documentation" ],
      sm = {};

  for ( var p in props ) {
    sm[props[p]] = m[props[p]];
  }

  sm.input  = aq.collect(m.input, i => plan.serialize_module_io(i));
  sm.output = aq.collect(m.output, o => plan.serialize_module_io(o));  

  sm.children = aq.collect(m.children, c => plan.serialize_module(c));
  sm.wires = aq.collect(m.wires, w => w.serialize())

  return sm;

}

AQ.Plan.record_methods.serialize_module_io = function(io) {

  var plan = this,
      props = [ "id", "x", "y", "width", "height", "model" ],
      sio = {};

  for ( var p in props ) {
    sio[props[p]] = io[props[p]];
  }  
  
  return sio;

}

AQ.Operation.record_methods.serialize = function() {

  var op = this;

  return {
    id: op.id,
    operation_type_id: op.operation_type_id,
    field_values: aq.collect(op.field_values, fv => {
      var efv = fv.serialize();
      efv.allowable_field_type_id = op.form[fv.role][fv.name] && op.form[fv.role][fv.name].aft ? 
                                    op.form[fv.role][fv.name].aft.id :
                                    null;
      if ( !fv.field_type.array && fv.routing ) {
        op.assign_sample(efv,op.routing[fv.routing])
      }
      return efv;
    }),
    status: op.status,
    user_id: op.user_id,
    x: op.x,
    y: op.y,
    routing: op.routing,
    rid: op.rid,
    parent_id: op.parent_id
  };

}

AQ.FieldValue.record_methods.serialize = function() {

  var fv = this,
      props = [ "id", "name", "child_item_id",, "child_sample_id", "value", "role", 
                "field_type_id", "item", "row", "column", "row", "column",
                "parent_class", "parent_id", "routing", "rid" ],
      efv = {};

  aq.each(props, p => efv[p] = fv[p]); 


  if ( fv.field_type.array ) {
    efv.array = true;
  }

  return efv;

}

AQ.Wire.record_methods.serialize = function() {

  var w = this;

  return {
    id: w.id,
    from_id: w.from_id,
    to_id: w.to_id,
    from: { rid: this.from.rid },
    to: { rid: this.to.rid },
    active: w.active,
    rid: w.rid
  }

}