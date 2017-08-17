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

  $scope.connect = function(from, from_object, to, to_object) {

    // console.log(["connect", from.record_type, from_object.record_type, to.record_type, to_object.record_type])

    if ( from.record_type == "FieldValue" && to.record_type == "FieldValue" ) {
      connect_fv_to_fv(from,from_object,to,to_object);
    } else if ( from.record_type == "ModuleIO" && to.record_type == "FieldValue" ) {
      from_object.connect_to_op(from, to, to_object);
      // from_object.compute_full_wires($scope.plan);
    } else if ( from.record_type == "FieldValue" && to.record_type == "ModuleIO" ) {
      to_object.connect_from_op(to, from, from_object)
    } else if ( from.record_type == "ModuleIO" && to.record_type == "ModuleIO" ) {
      // TODO: CHECK THAT THE USER IS NOT CONNECTING A MODULE INPUT TO THE SAME MODULE OUTPUT
      from_object.connect_to_module(from,to,to_object);
    } 

  }

}