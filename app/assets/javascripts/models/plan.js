AQ.Plan.record_methods.upgrade = function() {
  var plan = this;
  plan.operations = aq.collect(plan.operations, (op) => {
    var operation = AQ.Operation.record(op);
    operation.mode = 'io' // This is for the launcher
    operation.field_values = aq.collect(operation.field_values,(fv) => {
      return AQ.FieldValue.record(fv);  
    })
    op.jobs = aq.collect(op.jobs, job => {
      return AQ.Job.record(job);
    });    
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
      {methods: [ "field_values", "operation_type", "jobs" ] }
    ).then(ops => {
      plan.operations = ops;
      plan.recompute_getter('costs');
      aq.each(plan.operations, op => {
        op.field_values = aq.collect(op.field_values,(fv) => {
          return AQ.FieldValue.record(fv);  
        })
        op.jobs = aq.collect(op.jobs, job => {
          return AQ.Job.record(job);
        });
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

AQ.Plan.record_methods.submit = function(user) {

  var plan = this.export(),
      user_query = user ? "?user_id=" + user.id : "";

  return new Promise(function(resolve,reject) {
    AQ.post('/launcher/submit'+user_query,plan).then(
      (response) => {
        resolve(AQ.Plan.record(response.data).upgrade());
      }, (response) => {
        reject(response.data.errors);
      }
    );
  });

}

AQ.Plan.record_methods.cost_to_amount = function(c) {
  c.base = c.materials + c.labor * c.labor_rate;
  c.total = c.base * ( 1.0 + c.markup_rate );
  return c.total;
}

AQ.Plan.record_methods.estimate_cost = function() {

  var plan = this;
  plan.estimating;

  if ( !plan.estimating ) {
  
    plan.estimating = true;
    var exported_plan = plan.export();

    AQ.post('/launcher/estimate',exported_plan).then( response => {

      if ( response.data.errors ) {

        plan.cost = { error: response.data.errors };

      } else {

        var errors = [];

        plan.cost = {
          messages: response.data.messages,
          costs: response.data.costs,
          total: aq.sum(response.data.costs, c => {
            if ( c.error ) {
              errors.push(c.error.replace(/\(eval\)/g, 'cost'));
              return 0;
            } else {
              return plan.cost_to_amount(c);
            }
          })
        };

        if ( errors.length > 0 ) {
          plan.cost.error = errors.join(", ");
        }

      } 

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

AQ.Plan.record_getters.cost_total = function() {
  delete this.cost_total;
  this.costs;
}

AQ.Plan.record_getters.costs = function() {

  var plan = this;
  delete plan.costs;
  plan.costs = [];

  AQ.get('/plans/costs/'+plan.id).then(response => {

    plan.costs = response.data;
    plan.cost_total = 0;
    plan.cost_so_far = 0;

    aq.each(plan.costs, cost => {
      aq.each(plan.operations, op => {
        if ( cost.id == op.id ) {
          op.cost = cost;
          plan.cost_total += plan.cost_to_amount(cost);
          if ( op.status == "done" ) {
            plan.cost_so_far += plan.cost_to_amount(cost);
          }
        }
      })
    })

  });

  return plan.costs;

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

AQ.Plan.list = function(offset,user) {

  var user_query = user ? "&user_id=" + user.id : "";

  return new Promise(function(resolve,reject) {
    AQ.get('/launcher/plans?offset='+offset+user_query).then(
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
            operation.jobs = aq.collect(op.jobs, job => {
              return AQ.Job.record(job);
            });            
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

  var wire = AQ.Wire.record({
      from_op: from_op,
      from: from,
      to_op: to_op,
      to: to,
      from_id: from.rid,
      to_id: to.rid
    });

  plan.wires.push(wire);

  to.wired = true;
  from.wired = true;

  return wire;

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

AQ.Plan.record_methods.is_wired = function(op,fv) {

  var plan = this,
      found = false;

  aq.each(plan.wires, (wire) => {  
    if ( wire.to_op == op && wire.to == fv ) {
      found = true;
    }
  });

  return found;

}

AQ.Plan.record_methods.propagate_down = function(fv,sid) {

  var plan = this;

  aq.each(plan.wires, wire => {
    if ( wire.to.rid === fv.rid ) {
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

  var plan = this;

  if ( ! fv.field_type.array ) {

    aq.each(op.field_values,io => {
      if ( fv.route_compatible(io) ) {
        plan.propagate_down(io,sid)
      }  
    })

  } else {

    plan.propagate_down(fv,sid)

  }


  plan.propagate_up(op,fv,sid);

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

AQ.Plan.record_methods.add_wire = function(fv,op,pred) {

  var plan = this;

  var preop = AQ.Operation.record({
    routing: {},
    form: { input: {}, output: {} }
  }).set_type(pred.operation_type);

  plan.operations.push(preop)

  console.log("add_wire to " + op.operation_type.name + "(" + op.rid + ") from "
                             + preop.operation_type.name + "(" + preop.rid + ") via "
                             + fv.name + "(" + fv.rid + ")" );  

  var preop_output = preop.output(pred.output.name);

  plan.remove_wires_to(op,fv);
  var wire = plan.wire(preop,preop_output,op,fv);

  if ( fv.field_type.array ) {
    plan.propagate(op,fv,fv.sample_identifier);
  } else {
    plan.propagate(op,fv,op.routing[fv.routing])  
  }

  return preop;

}

AQ.Plan.record_methods.remove_wire = function(wire) {

  var plan = this;
  aq.remove(plan.wires, wire);
  aq.each(plan.operations,op => {
    aq.each(op.field_values, fv => {
      fv.wired = false;
    });
  });
  aq.each(plan.wires, w => {
    w.to.wired = true;
    w.from.wires = true;
  });

}

AQ.Plan.record_methods.debug = function() {

  var plan = this;
  plan.debugging = true;

  return new Promise(function(resolve,reject) {  

    AQ.get("/plans/" + plan.id + "/debug").then(
      response => {
        console.log(response);
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

AQ.Plan.record_methods.wire_aux = function(op, wires, operations) {

  var plan = this;

  aq.each(wires, w => {
    var fv = op.field_value_with_id(w.to_id);
    if ( fv ) {
      aq.each(operations,from_op => {
        var from_fv = from_op.field_value_with_id(w.from_id);
        if ( from_fv ) {
          var new_from_op = from_op.copy(),
              new_from_fv = new_from_op.field_value_like(from_fv);
          plan.wire(new_from_op, new_from_fv, op, fv)
              .wire_aux(new_from_op,wires, operations);
        }
      });
    }
  });

}

AQ.Plan.record_methods.copy = function() {

  var old_plan = this;

  return new Promise(function(resolve, reject) {

    AQ.Plan.where({id: old_plan.id},{methods: ['wires','goals']}).then( plans => {

      var plan = AQ.Plan.record(plans[0]),
          new_plan = AQ.Plan.record({});

      new_plan.operations = aq.collect(plan.goals, g => {
        return AQ.Operation.record(g).copy();
      });

      aq.each(new_plan.operations, op => {
        new_plan.wire_aux(op, plans[0].wires, old_plan.operations);
      });

      resolve(new_plan);

    });
  });

}


