(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('planCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                      function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }
    AQ.sce = $sce;

    $scope.snap = 16;
    $scope.last_place = 0;
    $scope.plan = AQ.Plan.record({operations: [], wires: []});

    AQ.User.active_users().then(users => {

      $scope.users = users;

      AQ.User.current().then((user) => {

        $scope.current_user = user;
        $scope.getting_plans = true;    

        AQ.OperationType.all_with_content(true).then((operation_types) => {

          $scope.operation_types = aq.where(operation_types,ot => ot.deployed);
          AQ.OperationType.compute_categories($scope.operation_types);
          AQ.operation_types = $scope.operation_types;

          AQ.get_sample_names().then(() =>  {
            console.log("Loading complete.");
          });

          $scope.$apply();

        });
      });
    });   

    // Actions ////////////////////////////////////////////////////////////////////////////////////

    $scope.add_operation = function(ot) {
      var op = AQ.Operation.record({
        x: $scope.snap + $scope.last_place, y: $scope.snap + $scope.last_place, width: 160, height: 30,
        routing: {}, form: { input: {}, output: {} }
      });
      $scope.last_place += 40;
      op.set_type(ot);
      $scope.current_op = op;
      $scope.plan.operations.push(op);
      document.getElementById("plan-editor-container").focus();
    }

    $scope.add_predecessor = function(fv,op,pred) {
      var newop = $scope.plan.add_wire(fv,op,pred);
      newop.x = op.x;
      newop.y = op.y + 3*$scope.snap;
      newop.width = 160;
      newop.height = 30;
      select(newop);
      var fvs = aq.where(newop.field_values, fv => fv.role == 'input');
      if ( fvs.length > 0 ) {
        $scope.current_fv = fvs[0];
      }
    }

    function select(object) {
      $scope.current_op   = object && object.model.model == "Operation"  ? object : null;
      $scope.current_fv   = object && object.model.model == "FieldValue" ? object : null;
      $scope.current_wire = object && object.model.model == "Wire"       ? object : null;
    }

    // Main Events ////////////////////////////////////////////////////////////////////////////////

    $scope.mouseDown = function(evt) {
      select(null);
    }

    $scope.mouseMove = function(evt) {
      if ( $scope.current_op && $scope.current_op.drag ) {
        $scope.current_op.x = evt.offsetX - $scope.current_op.drag.localX;
        $scope.current_op.y = evt.offsetY - $scope.current_op.drag.localY;
        $scope.last_place = 0;
      }   
    }    

    $scope.keyDown = function(evt) {

      switch(evt.key) {
        case "Backspace": 
          if ( $scope.current_wire ) {
            aq.remove($scope.plan.wires, $scope.current_wire);
            $scope.current_wire = null;
          }
          if ( $scope.current_op && !$scope.current_fv ) {
            aq.remove($scope.plan.operations, $scope.current_op);
            $scope.current_op = null;
            // TODO: Remove wires too
          }
          break;
        case "Escape":
          $scope.mouseDown(evt);
          break;
      }

    }    

    // Operation Events //////////////////////////////////////////////////////////////////////////    

    $scope.opMouseDown = function(evt,op) {

      select(op);

      $scope.current_op.drag = {
        localX: evt.offsetX - op.x, 
        localY: evt.offsetY - op.y
      };

      evt.stopImmediatePropagation();

    }

    $scope.opMouseUp = function(evt,op) {
      op.x = Math.floor((op.x+$scope.snap/2) / $scope.snap) * $scope.snap;
      op.y = Math.floor((op.y+$scope.snap/2) / $scope.snap) * $scope.snap;  
      delete op.drag;
    }

    $scope.opMouseMove = function(evt,op) {}

    // Field Value Events ///////////////////////////////////////////////////////////////////////

    $scope.fvMouseDown = function(evt,op,fv) {

      if ( $scope.current_fv && evt.shiftKey ) { // There is an fv already selected, so make a wire

        if ( $scope.current_fv.role == 'output' && $scope.current_fv.field_type.can_produce(fv) ) {

          $scope.plan.wires.push(AQ.Wire.record({
            from_op: $scope.current_op,
            from_id: $scope.current_fv.rid,
            from: $scope.current_fv,
            to_op: op,
            to_id: fv.rid,
            to: fv
          }));

        } else if ( fv.field_type.can_produce($scope.current_fv) ) {

          $scope.plan.wires.push(AQ.Wire.record({
            to_id: $scope.current_fv.rid,
            to_op: $scope.current_op,
            to: $scope.current_fv,
            from_id: fv.rid,
            from_op: op,
            from: fv
          }));

        }

      } else {
        select(op);
        $scope.current_fv = fv;
      }

      evt.stopImmediatePropagation();

    }    

    // Wire Events ////////////////////////////////////////////////////////////////////////////////

    $scope.wireMouseDown = function(evt, wire) {
      select(wire);
      evt.stopImmediatePropagation();         
    }

    // Computed Classes ///////////////////////////////////////////////////////////////////////////

    $scope.io_class = function(fv) {
      var c = "field-value";
      if ( fv == $scope.current_fv ) {
        c += " field-value-selected";
      } else if ( $scope.current_fv && $scope.current_fv.role == 'input' && fv.role == 'output' ) {
        if ( fv.field_type.can_produce($scope.current_fv) ) {
          c += " field-value-compatible";
        }
      } else if ( $scope.current_fv && $scope.current_fv.role == 'output' && fv.role == 'input' ) {
        if ( $scope.current_fv.field_type.can_produce(fv) ) {
          c += " field-value-compatible";
        }
      } 
      return c;
    }

  }]);

})();                    
