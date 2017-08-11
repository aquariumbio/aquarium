AQ.Plan.record_methods.serialize = function() {

  var plan = this, ops;

  return {
    id: plan.id,
    operations: aq.collect(plan.operations, op => op.serialize() ),
    wires: aq.collect(plan.wires, w => w.serialize() ),
    user_budget_association: plan.uba,
    status: plan.status,
    cost_limit: plan.cost_limit,
    name: plan.name,
    rid: plan.rid
  }

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
    rid: op.rid
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