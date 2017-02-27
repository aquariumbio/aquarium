AQ.Plan.record_methods.upgrade = function() {
  var plan = this;
  plan.operations = aq.collect(plan.operations, (op) => {
    var operation = AQ.Operation.record(op);
    operation.mode = 'io' // This is for the launcher
    operation.field_values = aq.collect(operation.field_values,(fv) => {
      return AQ.FieldValue.record(fv);  
    })
    return operation;
  });
  plan.open = true;
  plan.operations[0].open = true;
  return plan;
}

AQ.Plan.record_methods.submit = function() {

  var plan = this;

  return new Promise(function(resolve,reject) {
    AQ.post('/launcher/submit',plan).then(
      (response) => {
        resolve(AQ.Plan.record(response.data).upgrade());
      }, (response) => {
        reject(response.data.errors);
      }
    );
  });

}

AQ.Plan.record_methods.link_operation_types = function(operation_types) {

  aq.each(this.operations,(operation) => {
    operation.operation_type = aq.find(operation_types,(ot) => { 
      return ot.id == operation.operation_type.id 
    } );
  });

}

AQ.Plan.list = function(offset) {

  return new Promise(function(resolve,reject) {
    AQ.get('/launcher/plans?offset='+offset).then(
      (response) => {
        AQ.Plan.num_plans = response.data.num_plans;
        resolve(aq.collect(response.data.plans,(p) => { 
          var plan = AQ.Plan.record(p);
          plan.operations = aq.collect(plan.operations,(op) => {
            var operation = AQ.Operation.record(op);
            operation.mode = 'io'; // This is for the launcher UI, should probably be moved somewhere
            operation.field_values = aq.collect(
              aq.where(response.data.field_values, (fv) => {
                return fv.parent_id == operation.id;
              }), (fv) => { return AQ.FieldValue.record(fv); })
            return operation;
          });
          return plan;
        }));
      }, (response) => {
        reject(response.data.errors);
      }
    );
  });

}

AQ.Plan.record_methods.wire = function(from_op, from, to_op, to) {

  var plan = this;
  if ( !plan.wires ) {
    plan.wires = [];
  }

  plan.wires.push(
    AQ.Wire.record({
      from_op: from_op,
      from: from,
      to_op: to_op,
      to: to
    })
  );

  return plan;

}

AQ.Plan.record_methods.unwire = function(op) {

  var plan = this;

  aq.each(plan.wires, (wire) => {
    if ( wire.from_op == op || wire.to_op == op ) {
      aq.remove(plan.wires,wire);
    }
  });

}

AQ.Plan.record_methods.propagate_down = function(fv,sid) {

  var plan = this;

  aq.each(plan.wires, (wire) => {
    if ( wire.to == fv ) {
      wire.from_op.routing[wire.from.routing] = sid;
      wire.from_op.update_cost();
      aq.each(wire.from_op.field_values,(fv) => {
        plan.propagate_down(fv,sid);
      })
    }
  });

  return plan;

}

AQ.Plan.record_methods.propagate_up = function(op,fv,sid) {

  var plan = this,
      routing = fv.routing;

      console.log("propagate_up: " + op.operation_type.name + ", " + fv.name + ", " + routing + ", "  + sid)

  aq.each(op.field_values,(fv) => {
    if ( fv.routing == routing ) {
      aq.each(plan.wires, (wire) => {
        if ( wire.from == fv ) {
          wire.to_op.routing[wire.to.routing] = sid;
          wire.to.sample_identifier = sid;
          wire.to_op.update_cost();
          aq.each(wire.to_op.field_values,(to_fv) => {
            plan.propagate_up(wire.to_op,to_fv,sid)
          })
        }
      })
    }
  })

  return plan;

}

AQ.Plan.record_methods.propagate = function(op,fv,sid) {
  return this.propagate_down(fv,sid)
             .propagate_up(op,fv,sid);
}
