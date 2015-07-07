
function setDiagramParameters($scope) {
  // This function is here because connection.js will evaluate before
  // all the other js in this directory. Lame!  
  $scope.nameHeight = 20;
  $scope.width = 160;
  $scope.portSpace  = 14;
  $scope.textOffset = 8;
  $scope.cPoint = 40;
}

(function() {

  var w;
  try {
    w = angular.module('workflow'); 
  } catch (e) {
    w = angular.module('workflow', []); 
  } 

  w.directive("connections", function() {
    return {
      restrict: 'A',
      scope: { workflow: "=" },
      templateUrl: "/workflow/diagram/connections.html"
    }
  });   

  function pluck_operation ( operations, id ) {
    for ( var i=0; i<operations.length; i++ ) {
      if ( operations[i].id == id ) {
        return operations[i];
      }
    }
    return null;
  }

  function outputPosition($scope,op,name) {
    var i=0
    while(i < op.outputs.length && op.outputs[i].name != name) {
      i++;
    }
    if ( i< op.outputs.length ) {
      return (i+1)*$scope.portSpace + $scope.nameHeight;
    } else {
      return 0;
    }
  }

  function inputPosition($scope,op,name) {
    var i=0
    while(i < op.inputs.length && op.inputs[i].name != name) {
      i++;
    }
    if ( i < op.inputs.length ) {
      return (i+1)*$scope.portSpace + $scope.nameHeight;
    } else {
      return 0;
    }
  }

  w.directive("connection", function() {
    return {
      restrict: 'A',
      scope: { connection: "=", operations: "=", io: "=" },

      link: function($scope, $element, $attr) {     

        $scope.draw = function() {

          setDiagramParameters($scope);

          var from_op = pluck_operation($scope.operations,$scope.connection.from[0]),
                to_op = pluck_operation($scope.operations,$scope.connection.to[0]),
            from_part = $scope.connection.from[1],
              to_part = $scope.connection.to[1];

          if ( from_op && to_op ) {
            var ip = inputPosition($scope,to_op.operation,to_part),
                op = outputPosition($scope,from_op.operation,from_part);
          }

          if ( from_op && to_op && ip > 0 && op > 0 ) {

            var x1 = from_op.x + $scope.width,
                y1 = from_op.y + op,
                x2 = to_op.x,
                y2 = to_op.y + ip;
     
            $attr.$set("d", 
              "M " + x1 + " " + y1 + " " +
              "C " + (x1+$scope.cPoint) + " " + y1 + " "
                   + (x2-$scope.cPoint) + " " + y2 + " "
                   + x2 + " " + y2 );

          } else {

              $attr.$set("d", "");

          }

        }

        // Note: third arg causes $watch to look at the whole object
        $scope.$watch('operations', function(o,n,s) { s.draw(); }, true );

        // Note: third arg causes $watch to look at the whole object
        $scope.$watch('io', function(o,n,s) { s.draw(); }, true );        

      }
    }
  }); 

})();