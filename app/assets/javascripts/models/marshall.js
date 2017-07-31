AQ.OperationType.record_methods.marshall = function() {
  
  var ot = this;

  ot.field_types = aq.collect(ot.field_types, rft => {
    return AQ.FieldType.record(rft);
  })

  return ot;

}

AQ.Operation.record_methods.marshall = function() {

  var op = this;

  op.operation_type = AQ.OperationType.record(op.operation_type).marshall();

  op.field_values = aq.collect(op.field_values,(fv) => {
    var ufv = AQ.FieldValue.record(fv);
    aq.each(op.operation_type.field_types, ft => {
      if ( ft.role == ufv.role && ft.name == ufv.name ) {
        ufv.field_type = ft;
      }
    });
    return ufv;
  })

  op.routing = {};
  op.form = { input: {}, output: {} };

  aq.each(op.field_values, fv => {
    aq.each(op.operation_type.field_types,ft => {
      if ( ft.name == fv.name && ft.role == fv.role ) {
        fv.field_type = ft;
      }
    })
    op.routing[fv.field_type.routing] = fv.sid();
    op.form[fv.role][fv.name] = { aft_id: fv.allowable_field_type_id, aft: fv.aft }
  });

  op.jobs = aq.collect(op.jobs, job => {
    return AQ.Job.record(job);
  });

  op.width = 160;
  op.height = 30; 

  return op;  

}

AQ.Plan.record_methods.marshall = function() {

  var plan = this;
  plan.operations = aq.collect(plan.operations, (op) => AQ.Operation.record(op).marshall());
  plan.wires = aq.collect(plan.wires, wire => AQ.Wire.record(wire));

  aq.each(plan.wires, w => {
    w.snap = 16;
    aq.each(plan.operations, o => {
      aq.each(o.field_values, fv => {
        if ( w.to_id == fv.id ) {
          w.to = fv;
          w.to_op = o;
          o.num_wires++;
        }
        if ( w.from_id == fv.id ) {
          w.from = fv;
          w.from_op = o;
          o.num_wires++;
        }
        fv.recompute_getter("num_wires");
      })
      o.recompute_getter("types_and_values")
      o.recompute_getter('num_inputs');
      o.recompute_getter('num_outputs');       
    })   
  })

  plan.open = true;
  return plan;

}

