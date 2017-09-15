AQ.Plan.record_methods.reachable = function(a,b) {

  var plan = this;

  // Unmark all fvs
  plan.unmark();

  if ( a.role == 'input' ) {
    return plan.reachable_aux(plan.parent_of(a),a,b);
  } else {
    return plan.reachable_aux(plan.parent_of(b),b,a);    
  }

}

AQ.Plan.record_methods.unmark = function(a,b) {

  var plan = this;

  aq.each(plan.operations, op => {
    aq.each(op.field_values, fv => {
      fv._marked = false;
    })
  })

}

AQ.Plan.record_methods.parent_of = function(x) {

  var plan = this, 
      parent;

  aq.each(plan.operations, op => {
    aq.each(op.field_values, fv => {
      if ( fv == x ) {
        parent = op;
      }
    })
  })

  return parent;

}

AQ.Plan.record_methods.wires_out = function(op) {

  var plan = this,
      wires = [];

  aq.each(op.field_values, fv => {
    aq.each(plan.wires, w => {
      if ( w.from_op == op ) {
        wires.push(w);
      }
    })
  })      

  return wires;

}

AQ.Plan.record_methods.wires_from= function(fv) {

  var plan = this;
  return aq.where(plan.wires, w => w.from == fv);

}

AQ.Operation.record_methods.is_output = function(fv) {
  return this.outputs().includes(fv);
}

AQ.Plan.record_methods.reachable_aux = function(op,a,b) { // excpects that a is an input of op and b is an output of some possibly different op

  var plan = this;

  if ( a._marked ) {

    return false;

  } else if ( op.is_output(b) ) { // b is an output of the op containing a

    return true;

  } else { 

    var wires = plan.wires_out(op);

    if ( wires.length == 0 ) { // there are no output wires from the op containing fv  

      return false;

    } else {

      var result = false;

      a._marked = true;

      // for each output o of the op containing a
      aq.each(op.outputs(), ofv => {
        // for each wire ofv => x
        aq.each(plan.wires_from(ofv), wire => {
          result = result || plan.reachable_aux(wire.to_op,wire.to,b);
        });
      });

    }

    return result;

  }

}
