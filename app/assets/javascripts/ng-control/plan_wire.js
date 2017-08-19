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

      var parent;

      if ( object1.parent_id != object2.parent_id ) { // wire connects a module io block with an operation
        parent = object1;
      } else { // wire connects a module io pin to an operation
        parent = $scope.plan.current_module;
      }      

      if ( io2.role == 'input') {
        parent.connect_mod_to_op(io1, object1, io2, object2);
      } else {
        parent.connect_mod_from_op(io1, object1, io2, object2);
      }

    } else if ( io1.record_type == "FieldValue" && io2.record_type == "ModuleIO" ) {

      var parent;

      if ( object1.parent_id != object2.parent_id ) { // wire connects a module io block with an operation
        parent = object2;
      } else { // wire connects a module io pin to an operation
        parent = $scope.plan.current_module;
      }

      if ( io1.role == 'output' ) {
        parent.connect_mod_from_op(io2, object2, io1, object1)
      } else {
        parent.connect_mod_to_op(io2, object2, io1, object1);        
      }

    } else if ( io1.record_type == "ModuleIO" && io2.record_type == "ModuleIO" ) {

      // TODO: CHECK THAT THE USER IS NOT SIMPLY CONNECTING A MODULE INPUT TO THE SAME MODULE OUTPUT
      object1.connect_to_module(io1,io2,object2);

    } 

  }

}