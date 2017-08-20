function PlanWire($scope,$http,$attrs,$cookies,$sce,$window) {

  function has_cycle(a,b) {
   if ( $scope.plan.reachable(a,b) ) {
     alert("Cyclic plans are not currently supported. Cannot add wire.");
     return true;
   } else {
     return false;
   }
  }

  function connect_fv_to_fv(from, from_op, to, to_op) {

    if ( from.role == 'output' && from.field_type.can_produce(to) ) {
      if ( ! has_cycle(to, from ) ) {
        $scope.plan.wires.push(AQ.Wire.make({
          from_op: from_op,
          from: from,
          to_op: to_op,
          to: to,
          snap: $scope.snap
        }));
      }
    } else if ( to.field_type.can_produce(from) ) {
      if ( ! has_cycle(from,to) ) {
        $scope.plan.wires.push(Wire.make({
          to_op: from_op,
          to: from,
          from_op: to_op,
          from: to,
          snap: $scope.snap
        }));
      }
    }

  }

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

  $scope.connect = function(io1, object1, io2, object2) {

    var module = $scope.plan.current_module,
        role1 = object1.role(io1),
        role2 = object2.role(io2);

    if ( io1.record_type == "FieldValue" && io2.record_type == "FieldValue" ) {                 // 33

      connect_fv_to_fv(io1,object1,io2,object2);

    } else { 

      if ( object1.parent_id != object2.parent_id ) {                                           // 12, 13, 21, or 31

        if ( object1.record_type == "Module" && object2.record_type == "Module" ) {             // 12 or 21

          if ( object2.parent_id == object1.id ) {                                              // 12
            if ( role1 == 'input'  && role2 == 'input' )  module.connect(io1, object1, io2, object2);
            if ( role1 == 'output' && role2 == 'output' ) module.connect(io2, object2, io1, object1);
          } else if ( object1.parent_id == object2.id ) {                                       // 21
            if ( role1 == 'input'  && role2 == 'input' )  module.connect(io2, object2, io1, object1);
            if ( role1 == 'output' && role2 == 'output' ) module.connect(io1, object1, io2, object2);            
          } 

        } else {                                                                                 // 13 or 31

          if ( object1.record_type == "Module" && object2.record_type == "Operation" ) {         // 13
            if ( role1 == 'input' && role2 == 'input' )   module.connect(io1, object1, io2, object2);
            if ( role1 == 'output' && role2 == 'output' ) module.connect(io2, object2, io1, object1);
          } else {                                                                               // 31
            if ( role2 == 'input' && role1 == 'input' )   module.connect(io2, object2, io1, object1);
            if ( role2 == 'output' && role1 == 'output' ) module.connect(io1, object1, io2, object2);
          }

        }

      } else {                                                                                   // 11, 22, 23, 32

          if ( object1 == object2 ) {                                                            // 11
            console.log("Cannot connect io ports within the same module.")
          } else {                                                                               // 22, 23, 32
            if ( role1 == 'output' && role2 == 'input' ) module.connect(io1, object1, io2, object2);
            else module.connect(io2, object2, io1, object1);
          } 

      }

    }

  }

}