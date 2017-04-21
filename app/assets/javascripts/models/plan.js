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
  return plan;
}

AQ.Plan.record_methods.reload = function() {

  var plan = this;
  plan.recompute_getter('data_associations');

  AQ.PlanAssociation.where({plan_id: plan.id}).then(pas => {
    AQ.Operation.where(
      {id: aq.collect(pas,pa => pa.operation_id)},
      {methods: [ "field_values", "operation_type" ] }
    ).then(ops => {
      plan.operations = ops;
      aq.each(plan.operations, op => {
        op.field_values = aq.collect(op.field_values,(fv) => {
          return AQ.FieldValue.record(fv);  
        })
        op.reload().then(op => {
          op.open = false;
          AQ.update();
        });
      });
    });
  });

}

AQ.Plan.record_methods.export = function() {

  var plan = this;

  return AQ.Plan.record({
    operations: plan.operations_from_wires(),
    wires: plan.wires,
    user_budget_association: plan.uba
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

AQ.Plan.record_methods.estimate_cost = function() {

  var plan = this;
  plan.estimating;

  if ( !plan.estimating ) {
  
    plan.estimating = true;

    AQ.post('/launcher/estimate',plan.export()).then( response => {

      if ( response.data.errors ) {

        plan.cost = { error: response.data.errors };

      } else {

        var error = false;

        plan.cost = {
          costs: response.data,
          total: aq.sum(response.data, c => {
            if ( c.error ) {
              error = true;
              return 0;
            } else {
              c.base = c.materials + c.labor * c.labor_rate;
              c.total = c.base * ( 1.0 + c.markup_rate );
              return c.total;
            }
          })
        };

        plan.cost.error = error;

      }

      aq.each(response.data, cost => {
        console.log(cost);
      });      

      aq.each(plan.operations_from_wires(), op => {
        aq.each(response.data, cost => {
          if ( op.rid == cost.rid ) {
            if ( !cost.error ) {
              op.cost = cost.total;  
            } else {
              op.cost = cost.error;
            }
          }
        });
      });

      plan.estimating = false;

    });

  }

}

AQ.Plan.record_methods.cancel = function(msg) {

  var plan = this;

  return new Promise(function(resolve,reject) {  
    AQ.get('/plans/cancel/' + plan.id + "/" + msg).then(
      (response) => { 
        plan.reload();
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

  aq.each(plan.wires, wire => {
    if ( wire.to == fv ) {
      wire.from_op.routing[wire.from.routing] = sid; 
      if ( wire.from.role == 'output' ) {
        wire.from_op.instantiate(plan,wire.from,sid)
      }
      aq.each(wire.from_op.field_values, subfv => {
        if ( wire.from.route_compatible(subfv) ) {
          plan.propagate_down(subfv,sid);
        }
      })
    }
  });

  return plan;

}

AQ.Plan.record_methods.propagate_up = function(op,fv,sid) {

  var plan = this;

  aq.each(op.field_values, other_fv => {
    if ( fv.route_compatible(other_fv) ) {
      aq.each(plan.wires, wire => {
        if ( wire.from == other_fv ) {
          wire.to_op.routing[wire.to.routing] = sid;
          wire.to.sample_identifier = sid;
          aq.each(wire.to_op.field_values, to_fv => {
            if ( to_fv.route_compatible(wire.to) ) {
              plan.propagate_up(wire.to_op,to_fv,sid)
            }
          })
        }
      })
    }
  })

  return plan;

}

AQ.Plan.record_methods.propagate = function(op,fv,sid) {

  aq.each(op.field_values,io => {
    if ( fv.route_compatible(io) ) {
      this.propagate_down(io,sid)
    }  
  })

  this.propagate_up(op,fv,sid);

  return this;

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

AQ.Plan.record_methods.debug = function() {

  var plan = this;
  plan.debugging = true;

  return new Promise(function(resolve,reject) {  

    AQ.get("/plans/" + plan.id + "/debug").then(
      response => {
        plan.reload();
        plan.debugging = false;
      }
    );

  });
  
}

AQ.Plan.record_methods.relaunch = function() {

  var plan = this;

  return new Promise(function(resolve,reject) {
    AQ.get("/launcher/" + plan.id + "/relaunch").then(
      response => {
        var p = AQ.Plan.record(response.data.plan).upgrade();
        resolve(p,response.data.issues)
      },
      response => reject(null,response.data.issues)
    )
  });

}

AQ.Plan.getter(AQ.Budget,"budget");
