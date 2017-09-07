function PlanClasses($scope,$http,$attrs,$cookies,$sce,$window) {

  // Computed Classes ///////////////////////////////////////////////////////////////////////////

  $scope.op_class = function(op) {
    var c = "op";
    if ( op == $scope.current_draggable || op.multiselect ) {
      c += " op-selected";
    }
    return c;
  }

  $scope.io_class = function(op,fv) {

    var c = "field-value";

    if ( fv ) {

      if ( $scope.current_fv && 
           $scope.current_fv.role == 'input' && 
           fv.role == 'output' && 
           fv.field_type.can_produce($scope.current_fv) ) {

        c += " field-value-compatible";

      } else if ( $scope.current_fv && 
                  $scope.current_fv.role == 'output' && 
                  fv.role == 'input' && 
                  $scope.current_fv && 
                  $scope.current_fv.field_type.record_type == "FieldType" &&
                  $scope.current_fv.field_type.can_produce(fv) ) {

        c += " field-value-compatible";

      } else if ( fv.valid() ) {
        c += " field-value-valid";
      } else {
        c += " field-value-invalid";
      }

    }

    return c;

  }

  $scope.module_io_class = function(io, role) {

    var fv = null,
        op = null;

    if ( role == 'input' ) {
      if ( io.destinations && io.destinations.length > 0 ) {
        fv = io.destinations[0].io;
        op = io.destinations[0].op;
      }
    } else if ( io.origin ) {
      fv = io.origin.io;
      op = io.origin.op;
    }

    return $scope.io_class(op,fv);

  }  

  $scope.wire_class = function(wire) {

    var c = wire == $scope.current_wire ? 'wire-selected' : 'wire';

    if ( !wire.consistent() ) {
      c += " wire-inconsistent";
    }

    return c;

  }

  $scope.wire_arrow_class = function(wire) {

    var c = wire == $scope.current_wire ? 'wire-arrowhead-selected' : 'wire-arrowhead';

    if ( !wire.consistent() ) {
      c += " wire-arrowhead-inconsistent";
    }

    return c;

  }

  $scope.parameter_class = function(op, fv) {
    var c = "parameter";
    if ( fv.value != undefined ) {
      c += " parameter-has-value";
    } else {
      c += " parameter-has-no-value";
    };
    return c;
  }

  $scope.parameter_io_class = function(io) {

    var c = "parameter";

    var fv = null,
        op = null;

    if ( io.destinations && io.destinations.length > 0 ) {
      fv = io.destinations[0].io;
      op = io.destinations[0].op;
    }

    return $scope.parameter_class(op,fv);
  }  

}