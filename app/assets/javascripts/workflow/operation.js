(function() {

  var w;
  try {
    w = angular.module('workflow'); 
  } catch (e) {
    w = angular.module('workflow', []); 
  } 

  w.directive("operation", function() {
    return {
      restrict: 'A',
      scope: { operation: "=" },
      templateUrl: "/workflow/diagram/operation.html",
      link: function($scope,$element,$attr) {
        setDiagramParameters($scope);
        $scope.mouseDown = function(obj) {        
          $scope.$root.selection = obj;               
        }
        $scope.exceptionTotalPorts = function(ex) {
          var i = 0, sum = 0;
          while($scope.operation.exceptions[i] != ex) {
            var n = $scope.operation.exceptions[i].outputs.length 
                  + $scope.operation.exceptions[i].data.length;
            sum += (n == 0 ? 1 : n);
            i += 1;
          }
          return sum;
        }
      }
    }
  });

  function new_ispec() {
    return {
      name: aq.rand_string(5), 
      description: "Description here", 
      is_part: false, 
      is_vector: false, 
      alternatives: []
    };
  }

  function new_keyval() {
    return {
      name: aq.rand_string(5), 
      type: { "type": "number" }
    };
  }  

  function new_exception() {
    return {
      name: aq.rand_string(5), 
      outputs: [],
      data: []
    };
  }  

  w.directive("op", function() {

    return {
      restrict: 'A',
      scope: { op: "=", github: "="  },
      templateUrl: "/workflow/editor/operation.html",
      link: function($scope,$element) {
        if ( $scope.op.workflow != $scope.$parent.workflow.id ) {        
          $element.find('input').attr('disabled',true);
          $element.find('button').attr('disabled',true);
        }
        $scope.addInput = function() {
          $scope.op.inputs.push(new_ispec());
          $scope.$root.selection = $scope.op.inputs.slice(-1)[0];
        }
        $scope.addOutput= function() {
          $scope.op.outputs.push(new_ispec());
          $scope.$root.selection = $scope.op.outputs.slice(-1)[0];
        }    
        $scope.addParam = function() {
          $scope.op.parameters.push(new_keyval());
          $scope.$root.selection = $scope.op.parameters.slice(-1)[0];
        }   
        $scope.addData = function() {
          $scope.op.data.push(new_keyval());
          $scope.$root.selection = $scope.op.data.slice(-1)[0];
        }         
        $scope.addException = function() {
          $scope.op.exceptions.push(new_exception());
          $scope.$root.selection = $scope.op.data.slice(-1)[0];
        }                          
      }
    }

  });

  w.directive("partName", function($compile) {

    update_part_name = function($scope, $element) {
      var displayName = $scope.partName;
      if ( displayName.length > 11 ) {
        displayName = displayName.substring(0,8) + "...";
      }
      $element.html(displayName);
    }

    return {
      restrict: 'A',
      replace: true,
      scope: { "partName": "=" },
      link: function($scope, $element, $attr) {
        update_part_name($scope,$element);
        $scope.$watch('partName', function() {
          update_part_name($scope,$element);
        });
      }
    }

  });  

  w.directive("exception", function() {
    return {
      restrict: 'A',
      scope: { exception: "=", oper: "="},
      templateUrl: "/workflow/editor/exception.html",
      link: function($scope,$element) {
        // TODO: Disable functions if parent operation is locked
        $scope.addOutput = function() {
          $scope.exception.outputs.push(new_ispec());
          $scope.$root.selection = $scope.exception.outputs.slice(-1)[0];
        }    
        $scope.addData = function() {
          $scope.exception.data.push(new_ispec());
          $scope.$root.selection = $scope.exception.data.slice(-1)[0];
        }         
      }
    }
  });  

})();
