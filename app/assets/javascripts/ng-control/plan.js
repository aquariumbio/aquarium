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

    $scope.snap = 20;

    AQ.Plan.where({id: 84},{ include: { "operations": { include: "operation_type" } }, methods: [ "wires" ] }).then(plans => {
      $scope.plan = plans[0];
      var y = 80;
      $scope.plan.operations = aq.collect($scope.plan.operations, op => {
        op = AQ.Operation.record(op);
        op.x = 100 + Math.random()*500; op.y = y; op.width = 160; op.height= 30;
        y += 80;
        op.operation_type = AQ.OperationType.record(op.operation_type)
        return op;
      });
      $scope.current_op = $scope.plan.operations[0];
      $scope.$apply();
    });

    // Main Events ////////////////////////////////////////////////////////////////////////////////

    $scope.mouseDown = function(evt) {
    }

    $scope.mouseMove = function(evt) {
      if ( $scope.current_op && $scope.current_op.drag ) {
        $scope.current_op.x = evt.offsetX - $scope.current_op.drag.localX;
        $scope.current_op.y = evt.offsetY - $scope.current_op.drag.localY;
      }   
    }    

    $scope.keyDown = function(evt) {
      console.log(evt);

      switch(evt.key) {
        case "Backspace": 
          if ( $scope.current_wire ) {
            console.log($scope.current_wire)
            aq.remove($scope.plan.wires, $scope.current_wire);
            $scope.current_wire = null;
          }
          break;
      }

    }    

    // Operation Events //////////////////////////////////////////////////////////////////////////    

    $scope.opMouseDown = function(evt,op) {

      console.log("op mouse down")

      $scope.current_wire = null;
      $scope.current_op = op;
      $scope.current_fv = null;

      $scope.current_op.drag = {
        localX: evt.offsetX - op.x, 
        localY: evt.offsetY - op.y
      };

    }

    $scope.opMouseUp = function(evt,op) {

      op.x = Math.floor((op.x+$scope.snap/2) / $scope.snap) * $scope.snap;
      op.y = Math.floor((op.y+$scope.snap/2) / $scope.snap) * $scope.snap;  

      delete op.drag;

    }

    $scope.opMouseMove = function(evt,op) {
      // if ( op.drag ) {
      //   op.x = evt.offsetX - op.drag.localX;
      //   op.y = evt.offsetY - op.drag.localY;
      // }      
    }

    // Field Value Events ///////////////////////////////////////////////////////////////////////

    $scope.fvMouseDown = function(evt,op,fv) {

      console.log(evt)
      console.log([fv.id,evt.shiftKey])

      if ( $scope.current_fv && evt.shiftKey ) { // There is an fv already selected, so make a wire

        if ( $scope.current_fv.role == 'output' ) {

          $scope.plan.wires.push(AQ.Wire.record({
            from_id: $scope.current_fv.id,
            to_id: fv.id
          }));

        } else {

          $scope.plan.wires.push(AQ.Wire.record({
            to_id: $scope.current_fv.id,
            from_id: fv.id
          }));

        }

      } else {
        console.log("selectin fv")
        $scope.current_wire = null;
        $scope.current_op = op;      
        $scope.current_fv = fv;
      }

    }    

    // Wire Events ////////////////////////////////////////////////////////////////////////////////

    $scope.wireMouseDown = function(evt, wire) {
      $scope.current_wire = wire;
      $scope.current_op = null;      
      $scope.current_fv = null;      
    }

  }]);

})();                    
