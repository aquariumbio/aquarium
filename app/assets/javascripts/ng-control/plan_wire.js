function PlanWire($scope,$http,$attrs,$cookies,$sce,$window) {

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                 | 1          | 2         | 3         |
  //                 | IO Block   | Module    | Operation |
  //                 | in    out  | in   out  | in    out | 
  // ----------------+-----+------+-----+-----+-----+-----+-
  // 1 IO Block   in | x     x    |       x   |       x   |
  //             out | x     x    | x         | x         |
  // ----------------+------------+-----------+-----------+-
  // 2 Module     in |       x    | x         | x         |
  //             out | x          |       x   |       x   |
  // ----------------+------------+-----------+-----------+-
  // 3 Operation  in |       x    | x         | x         |
  //             out | x          |       x   |       x   | 
  // ----------------+------------+-----------+-----------+-
  //

  $scope.connect = function(io1, object1, io2, object2) {
    $scope.plan.connect(io1, object1, io2, object2);
  };

}

AQ.Plan.record_methods.is_wired_to = function(io) {
  var plan = this;
  return plan.num_wires_into(io) > 0;
}


AQ.Plan.record_methods.connect_aux = function(io1, object1, io2, object2) {

  var plan = this,
      new_wire,
      cycle;

  console.log("connect_aux",io1, object1, io2, object2)

  new_wire = plan.current_module.connect(io1, object1, io2, object2);
  plan.base_module.associate_fvs();  
  cycle = plan.add_implied_wires();
  plan.recount_fv_wires();

  if ( cycle ) {
    plan.current_module.remove_wire(new_wire);
    plan.base_module.associate_fvs();    
    plan.recount_fv_wires();  
    alert("Cycle detected. Could not add wire.")
  }

}

AQ.Plan.record_methods.connect = function(io1, object1, io2, object2) {

  console.log(["plan.connect", io1, object1, io2, object2])

  var plan = this;

  var role1 = object1.role(io1),
      role2 = object2.role(io2);

  if ( io1.record_type == "FieldValue" && io2.record_type == "FieldValue" ) {                 // 33

    // TODO: Makes sure that object2 is not already in a wire
    if ( ! plan.is_wired_to ( io2 ) ) {
      plan.add_wire(io1,object1,io2,object2);
    } else {
      console.log("Fan in not allowed")
    }

  } else { 

    if ( object1.parent_id != object2.parent_id ) {                                           // 12, 13, 21, or 31


      if ( object1.record_type == "Module" && object2.record_type == "Module" ) {             // 12 or 21

        if ( object2.parent_id == object1.id ) {                                              // 12
          if ( role1 == 'input'  && role2 == 'input' )  plan.connect_aux(io1, object1, io2, object2);
          if ( role1 == 'output' && role2 == 'output' ) plan.connect_aux(io2, object2, io1, object1);
        } else if ( object1.parent_id == object2.id ) {                                       // 21
          if ( role1 == 'input'  && role2 == 'input' )  plan.connect_aux(io2, object2, io1, object1);
          if ( role1 == 'output' && role2 == 'output' ) plan.connect_aux(io1, object1, io2, object2);            
        } 

      } else {                                                                                 // 13 or 31

        if ( object1.record_type == "Module" && object2.record_type == "Operation" ) {         // 13
          if ( role1 == 'input' && role2 == 'input' )   plan.connect_aux(io1, object1, io2, object2);
          if ( role1 == 'output' && role2 == 'output' ) plan.connect_aux(io2, object2, io1, object1);
        } else {                                                                               // 31
          if ( role2 == 'input' && role1 == 'input' )   plan.connect_aux(io2, object2, io1, object1);
          if ( role2 == 'output' && role1 == 'output' ) plan.connect_aux(io1, object1, io2, object2);
        }

      }

    } else {                                                                                   // 11, 22, 23, 32


      if ( object1 == object2 ) {                                                              // 11
        alert("Cannot connect io ports within the same module.")
      } else {                                                                                 // 22, 23, 32
        if ( role1 == 'output' && role2 == 'input' ) plan.connect_aux(io1, object1, io2, object2);
        else if ( role1 == 'input' && role2 == 'output' ) plan.connect_aux(io2, object2, io1, object1);
      } 

    }

  }

}

AQ.Plan.record_methods.wire_equiv = function(wire1, wire2) {

  var r = wire1.from.rid == wire2.from.rid && wire1.to.rid == wire2.to.rid;
  return r;
}


AQ.Plan.record_methods.wire_in_set = function(wires, wire) {

  var rval = false;

  aq.each(wires, w => {
    if ( plan.wire_equiv(w, wire) ) rval = true;
  });

  return rval;

}

AQ.Plan.record_methods.get_implied_wires = function() {

  var plan = this, wires_from_modules = [];

  aq.each(plan.base_module.all_io, io => {
    if ( io.origin ) {
      aq.each(io.destinations, d => {
        wires_from_modules.push(AQ.Wire.record({
          from: io.origin.io,
          from_op: io.origin.op,
          to: d.io,
          to_op: d.op
        }));
      })
    }
  });

  return wires_from_modules;

}

AQ.Plan.record_methods.makes_cycle= function(wires) {

  var plan = this;

  console.log("Cycle?")

  for ( i in wires ) {
    console.log("    Checking for cycle: " + wires[i].to_s)
    if ( plan.reachable(wires[i].from, wires[i].to) ) {
      return true;
    }
  }

  return false;

}

AQ.Plan.record_methods.add_implied_wires = function() {

  var plan = this,
      wires_from_modules = plan.get_implied_wires(),
      wires_to_add = [],
      wires_to_delete = [];

  wires_to_add = aq.where(wires_from_modules, w => !plan.wire_in_set(plan.wires, w));

  if ( plan.makes_cycle(wires_to_add) ) {
    return true;
  } else {
    plan.wires = plan.wires.concat(wires_to_add);
    console.log("Added " + wires_to_add.length + " wires");
    return false;
  }

}

AQ.Plan.record_methods.delete_obsolete_wires = function(old_wires) {

  var plan = this, 
      new_wires = plan.get_implied_wires(),
      wires_to_delete = [];

  aq.each(plan.wires, w => {
    if ( plan.wire_in_set(old_wires,w) && !plan.wire_in_set(new_wires,w) ) {
      wires_to_delete.push(w);
    }
  })

  aq.each(wires_to_delete, w => aq.remove(plan.wires,w));

  console.log("Deleted " + wires_to_delete.length + " wires");  

}

AQ.Plan.record_methods.associated_wires = function(io) {

  var plan = this,
      dests = aq.collect(io.destinations, d => d.io);

  return aq.where(plan.wires, w => io.origin && w.from == io.origin.io && dests.includes(w.to));

}

