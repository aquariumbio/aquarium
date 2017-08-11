function PlanMouse($scope,$http,$attrs,$cookies,$sce,$window) {

  function all_ops(f) {
    aq.each($scope.plan.operations,f);
  }  

  function op_in_multiselect(op) {

    var m = $scope.multiselect;

    return  (( m.width >= 0 && m.x < op.x && op.x + op.width < m.x+m.width ) ||
             ( m.width <  0 && m.x + m.width < op.x && op.x + op.width < m.x )) &&
            (( m.height >= 0 && m.y < op.y && op.y + op.height < m.y+m.height ) ||
             ( m.height <  0 && m.y + m.height < op.y && op.y + op.height < m.y ));

  }  

 $scope.multiselect = {};

 $scope.mouseDown = function(evt) {

    $scope.select(null);
    all_ops(op => op.multiselect = false);

    $scope.multiselect = {
      x: evt.offsetX,
      y: evt.offsetY,
      width: 0,
      height: 0,
      active: true,
      dragging: false
    }      

  }

  $scope.mouseMove = function(evt) {

    if ( $scope.current_op && $scope.current_op.drag && !$scope.current_fv ) {

      $scope.current_op.x = evt.offsetX - $scope.current_op.drag.localX;
      $scope.current_op.y = evt.offsetY - $scope.current_op.drag.localY;
      $scope.last_place = 0;

    } else if ( $scope.multiselect.dragging ) {

      all_ops(op => {
        if ( op.multiselect ) {
          op.x = evt.offsetX - op.drag.localX;
          op.y = evt.offsetY - op.drag.localY;
        }
      });

    } else if ( $scope.multiselect.active ) {

      $scope.multiselect.width = evt.offsetX - $scope.multiselect.x;
      $scope.multiselect.height = evt.offsetY - $scope.multiselect.y;

    }

  }    

  $scope.mouseUp = function(evt) {

    if ( $scope.multiselect.dragging ) {
      $scope.multiselect.dragging = false;
    } else if ( $scope.multiselect.active  ) {
      all_ops(op => {
        if ( op_in_multiselect(op) ) {
          op.multiselect = true;
        }
      });
      $scope.multiselect.active = false;        
    }
  }

  // Operation Events //////////////////////////////////////////////////////////////////////////    

  $scope.opMouseDown = function(evt,op) {

    if ( op.multiselect ) {

      all_ops(op => {
        if ( op.multiselect ) {
          op.drag = {
            localX: evt.offsetX - op.x, 
            localY: evt.offsetY - op.y
          }
        }
      });

      $scope.multiselect.dragging = true;

    } else {

      $scope.select(op); 
      all_ops(op=>op.multiselect=false);
      $scope.current_op.drag = {
        localX: evt.offsetX - op.x, 
        localY: evt.offsetY - op.y
      };   

    }

    evt.stopImmediatePropagation();

  }

  function snap(op) {
    op.x = Math.floor((op.x+$scope.snap/2) / $scope.snap) * $scope.snap;
    op.y = Math.floor((op.y+$scope.snap/2) / $scope.snap) * $scope.snap;      
  }

  $scope.opMouseUp = function(evt,op) {

    if ( op.multiselect ) {
      aq.each($scope.plan.operations, op => snap(op));
      delete op.drag;
    } else {
      snap(op);
      delete op.drag;
    }        
    
  }

  $scope.opMouseMove = function(evt,op) {}

  $scope.multiselect_x = function() {
    return $scope.multiselect.width > 0 ? $scope.multiselect.x : $scope.multiselect.x + $scope.multiselect.width;
  }

  $scope.multiselect_y = function() {
    return $scope.multiselect.height > 0 ? $scope.multiselect.y : $scope.multiselect.y + $scope.multiselect.height;
  }    

  $scope.multiselect_width = function() {
    return Math.abs($scope.multiselect.width);
  }

  $scope.multiselect_height = function() {
    return Math.abs($scope.multiselect.height);
  }  

  // Field Value Events ///////////////////////////////////////////////////////////////////////

  $scope.fvMouseDown = function(evt,op,fv) {

    all_ops(op=>op.multiselect=false);

    if ( $scope.current_fv && evt.shiftKey ) { // There is an fv already selected, so make a wire

      var wire;

      if ( $scope.current_fv.role == 'output' && $scope.current_fv.field_type.can_produce(fv) ) {

        if ( $scope.plan.reachable(fv, $scope.current_fv) ) {

          alert("Cyclic plans are not currently supported. Cannot add wire.")

        } else {

          wire = AQ.Wire.make({
            from_op: $scope.current_op,
            from: $scope.current_fv,
            to_op: op,
            to: fv,
            snap: $scope.snap
          });

          $scope.plan.wires.push(wire);            

        }

      } else if ( fv.field_type.can_produce($scope.current_fv) ) {

        if ($scope.plan.reachable($scope.current_fv,fv)) {

          alert("Cyclic plans are not currently supported. Cannot add wire.")            

        } else {

          wire = AQ.Wire.make({
            to_op: $scope.current_op,
            to: $scope.current_fv,
            from_op: op,
            from: fv,
            snap: $scope.snap
          });

          $scope.plan.wires.push(wire);            

        }

      }

    } else {

      $scope.select(op);
      $scope.set_current_fv(fv,true);

    }

    evt.stopImmediatePropagation();

  }    

  // Wire Events ////////////////////////////////////////////////////////////////////////////////

  $scope.wireMouseDown = function(evt, wire) {
    $scope.select(wire);
    evt.stopImmediatePropagation();  
  }  

}