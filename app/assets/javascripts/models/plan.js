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

AQ.Plan.record_methods.reload = function() {

  var plan = this;
  plan.recompute_getter('data_associations');

  aq.each(plan.operations, op => {
    op.reload().then(op => {
      AQ.update();
    });
  })

}

AQ.Plan.record_methods.export = function() {

  var plan = this;

  return AQ.Plan.record({
    operations: plan.operations_from_wires(),
    wires: plan.wires
  })

}

AQ.Plan.record_methods.submit = function() {

  var plan = this.export();

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

AQ.Plan.record_methods.cancel = function(msg) {

  var plan = this;

  return new Promise(function(resolve,reject) {  
    AQ.get('/plans/cancel/' + plan.id + "/" + msg).then(
      (response) => { 
        console.log("A")
        plan.reload();
        console.log("B")
        resolve(response.data)
      },
      (response) => { reject(response.data.errors) }
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
            operation.mode = 'io'; // This is for the launcher UI.
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

  to.wired = true;

  return plan;

}

AQ.Plan.record_methods.unwire = function(op) {

  var plan = this;

  aq.each(plan.wires, (wire) => {
    if ( wire.from_op == op || wire.to_op == op ) {
      delete wire.to.wired;
      aq.remove(plan.wires,wire);
    }
  });

}

AQ.Plan.record_methods.remove_wires_to = function(op,fv) {

  var plan = this;

  aq.each(plan.wires, (wire) => {  
    if ( wire.to_op == op && wire.to == fv ) {
      aq.remove(plan.wires,wire);
    }
  });

  return plan;

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

AQ.Plan.record_methods.operations_from_wires = function() {

  var plan = this, 
      ops = [];

  aq.each(plan.operations,(op) => {
    ops.push(op);
  });

  aq.each(plan.wires, (wire) => {
    if ( ops.indexOf(wire.from_op) < 0 ) { 
      ops.push(wire.from_op);
    }
    if ( ops.indexOf(wire.to_op) < 0 ) { 
      ops.push(wire.to_op);
    }
  })

  return ops;

}

AQ.Plan.record_methods.cost = function() {

  var plan = this,
      sum = 0;

  aq.each(plan.operations_from_wires(),(op) => {
    if ( op.cost ) {
      sum += op.cost;
    }
  })    

  return sum;
}
