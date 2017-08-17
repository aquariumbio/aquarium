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

  $scope.connect = function(io1, object1, io2, object2) {


    if ( io1.record_type == "FieldValue" && io2.record_type == "FieldValue" ) {

      connect_fv_to_fv(io1,object1,io2,object2);

    } else if ( io1.record_type == "ModuleIO" && io2.record_type == "FieldValue" ) {

      if ( io2.role == 'input') {
        object1.connect_to_op(io1, io2, object2);
      } else {
        object1.connect_from_op(io1, io2, object2);
      }

    } else if ( io1.record_type == "FieldValue" && io2.record_type == "ModuleIO" ) {

      if ( io1.role == 'output' ) {
        object2.connect_from_op(io2, io1, object1)
      } else {
        object2.connect_to_op(io2, io1, object1);        
      }

    } else if ( io1.record_type == "ModuleIO" && io2.record_type == "ModuleIO" ) {

      // TODO: CHECK THAT THE USER IS NOT SIMPLY CONNECTING A MODULE INPUT TO THE SAME MODULE OUTPUT
      object1.connect_to_module(io1,io2,object2);

    } 

  }

}