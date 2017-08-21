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

  function is_wired_to(io) {
    console.log([io, $scope.plan.num_wires_into(io),$scope.plan.num_wires_into(io) > 0])
    return $scope.plan.num_wires_into(io) > 0;
  }

  function connect(io1, object1, io2, object2) {

    if ( !is_wired_to(io2) ) {
      $scope.plan.current_module.connect(io1, object1, io2, object2);
    } else {
      console.log("Fan in not allowed")
    }

  }

  $scope.connect = function(io1, object1, io2, object2) {

    var role1 = object1.role(io1),
        role2 = object2.role(io2);

    if ( io1.record_type == "FieldValue" && io2.record_type == "FieldValue" ) {                 // 33

      // TODO: Makes sure that object2 is not already in a wire
      if ( ! is_wired_to ( io2 ) ) {
        $scope.plan.connect(io1,object1,io2,object2);
      } else {
        console.log("Fan in not allowed")
      }

    } else { 

      if ( object1.parent_id != object2.parent_id ) {                                           // 12, 13, 21, or 31

        if ( object1.record_type == "Module" && object2.record_type == "Module" ) {             // 12 or 21

          if ( object2.parent_id == object1.id ) {                                              // 12
            if ( role1 == 'input'  && role2 == 'input' )  connect(io1, object1, io2, object2);
            if ( role1 == 'output' && role2 == 'output' ) connect(io2, object2, io1, object1);
          } else if ( object1.parent_id == object2.id ) {                                       // 21
            if ( role1 == 'input'  && role2 == 'input' )  connect(io2, object2, io1, object1);
            if ( role1 == 'output' && role2 == 'output' ) connect(io1, object1, io2, object2);            
          } 

        } else {                                                                                 // 13 or 31

          if ( object1.record_type == "Module" && object2.record_type == "Operation" ) {         // 13
            if ( role1 == 'input' && role2 == 'input' )   connect(io1, object1, io2, object2);
            if ( role1 == 'output' && role2 == 'output' ) connect(io2, object2, io1, object1);
          } else {                                                                               // 31
            if ( role2 == 'input' && role1 == 'input' )   connect(io2, object2, io1, object1);
            if ( role2 == 'output' && role1 == 'output' ) connect(io1, object1, io2, object2);
          }

        }

      } else {                                                                                   // 11, 22, 23, 32

        if ( object1 == object2 ) {                                                              // 11
          console.log("Cannot connect io ports within the same module.")
        } else {                                                                                 // 22, 23, 32
          if ( role1 == 'output' && role2 == 'input' ) connect(io1, object1, io2, object2);
          else if ( role1 == 'input' && role2 == 'output' ) connect(io2, object2, io1, object1);
        } 

      }

    }

  }

}