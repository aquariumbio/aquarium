
AQ.Plan.record_methods.cost_to_amount = function(c) {
  c.base = c.materials + c.labor * c.labor_rate;
  c.total = c.base * ( 1.0 + c.markup_rate );
  return c.total;
}

AQ.Plan.record_methods.estimate_cost = function() {

  var plan = this;

  if ( !plan.estimating ) {
  
    plan.estimating = true;
    var serializeed_plan = plan.serialize();

    return AQ.post('/launcher/estimate',serializeed_plan).then( response => {

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

      aq.each(plan.operations, op => {
        aq.each(response.data.costs, cost => {
          if ( op.id == cost.id ) {
            if ( !cost.error ) {
              op.cost = cost.total;  
            } else {
              op.cost = cost.error;
            }
          }
        });
      });

      plan.base_module.compute_cost(plan);

      plan.estimating = false;

    }).then(() => plan);

  } else {
    return Promise.resolve(plan);
  }

}

AQ.Plan.record_getters.cost_total = function() {
  delete this.cost_total;
  this.costs;
}


AQ.Plan.record_getters.transactions = function() {

  delete this.transactions;
  this.cost_so_far; // this will fetch plan.transactions when called te first time
  return [];        // return a temporary empty list for views to use

}

AQ.Plan.record_getters.cost_so_far = function() {

  let plan = this,
      opids = aq.collect(plan.operations, op => op.id);

  delete plan.cost_so_far;

  AQ.Account.where({operation_id: opids}).then(transactions => {
    plan.transactions = transactions;
    console.log(transactions)
    plan.cost_so_far = 0.0;
    aq.each(plan.operations, op => (op.cost_so_far = 0));
    aq.each(transactions, t => {
      if ( t.transaction_type == 'debit' ) {
        let amount = t.amount * (1+t.markup_rate);
        plan.cost_so_far += amount;
        aq.each(plan.operations, op => {
          if ( t.operation_id == op.id ) {
            op.cost_so_far += amount;
          }
        });
      } else {
        plan.cost_so_far -= amount;
        aq.each(plan.operations, op => {
          if ( t.operation_id == op.id ) {
            op.cost_so_far -= amount;
          }
        });
      }
    });
    AQ.update();
  });

  return plan.cost_so_far;

}

AQ.Plan.record_getters.costs = function() {

  var plan = this;
  delete plan.costs;
  plan.costs = [];

  console.log("computing costs")

  AQ.get('/plans/costs/'+plan.id).then(response => {

    plan.costs = response.data;
    plan.cost_total = 0;

    aq.each(plan.costs, cost => {
      aq.each(plan.operations, op => {
        if ( cost.id == op.id ) {
          cost.total = plan.cost_to_amount(cost);
          op.cost = cost.total;
          plan.cost_total += plan.cost_to_amount(cost);
          console.log("op.cost", op.cost)
          // if ( op.status == "done" ) {
          //   plan.cost_so_far += plan.cost_to_amount(cost);
          // }
        }
      })
    });

    console.log("Costs", plan.costs)

  });

  return plan.costs;

}