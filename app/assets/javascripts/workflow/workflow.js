(function() {

  var w;
  try {
    w = angular.module('workflow'); 
  } catch (e) {
    w = angular.module('workflow', []); 
  } 

  w.controller('workflowCtrl', function ($scope,$http,$attrs) {

    $scope.selection = null;

    $http.get('/workflows/' + $attrs.workflow + ".json")
      .success(function(data) {
        $scope.workflow = data;
        $scope.$root.workflow_id = data.id;
      })
      .error(function() {
        console.log("Could not retrieve workflow");
      });

    this.get_id = function() { return $scope.workflow.id };

    $scope.clearSelection = function() {
      $scope.$root.selection = null;
      $scope.$root.output_selected = null;
      $scope.$root.current_op = null;
    }

    $scope.delete_operation = function(h) {
      aq.delete_from_array($scope.workflow.specification.operations,h);
      $scope.$root.selection = null;
    }    

    $scope.selected = function(obj) {
      return $scope.$root.selection == obj;
    }

    $scope.$root.mouseDownForDrag = function($event,h) {
      $scope.dragging = h;
      $scope.mouseDownX = $event.offsetX - h.x;
      $scope.mouseDownY = $event.offsetY - h.y;
    }

    $scope.$root.mouseMoveForDrag = function($event) {
      if ( $scope.dragging ) {
        $scope.dragging.x = $event.offsetX - $scope.mouseDownX;
        $scope.dragging.y = $event.offsetY - $scope.mouseDownY;
      }
    }    

    $scope.$root.mouseUpForDrag = function() {
      $scope.dragging = null;
    }    

    $scope.$root.outputClick = function(op,part) {
      $scope.$root.selection = part;
      $scope.$root.output_selected = true;
      $scope.$root.current_op = op;
    }        

    $scope.$root.inputClick = function(op,part) {
      if ( $scope.$root.output_selected ) {
        $scope.workflow.specification.io.push ( { 
          to: [ op.id, part.name ],
          from: [ $scope.$root.current_op.id, $scope.$root.selection.name ]
        });
        $scope.clearSelection();
      }
    }

    $scope.$root.exOutputClick = function(operation,ex,part) {
      console.log("asd")
      $scope.$root.selection = part;
      $scope.$root.output_selected = true;
      $scope.$root.current_op = op;
    }

    $scope.$root.deletePart = function(op,type,part) {
      if ( type == "Input" ) {
        aq.delete_from_array(op.inputs,part);
      } else if ( type == "Output" ) {
        aq.delete_from_array(op.outputs,part);
      } else if ( type == "Data" ) {
        aq.delete_from_array(op.data,part);
      } else {
        aq.delete_from_array(op.parameters,part);
      }
      $scope.$root.selection = null;
    }

    $scope.$root.deleteException = function(op,ex) {
      aq.delete_from_array(op.exceptions,ex);
      $scope.$root.selection = op;
    }

  });

  angular.forEach(['x', 'y', 'width', 'height', 'cx', 'cy', 'transform', 'd', 'fill', 'class'], function(name) {
    var ngName = 'ng' + name[0].toUpperCase() + name.slice(1);
    w.directive(ngName, function() {
      return function(scope, element, attrs) {
        attrs.$observe(ngName, function(value) {
          attrs.$set(name, value); 
        })
      };
    });
  });

  w.directive('jsonText', function() {
    return {
      restrict: 'A',
      require: 'ngModel',
      link: function(scope, element, attr, ngModel) {            
        function into(input) {
          return JSON.parse(input);
        }
        function out(data) {
          return JSON.stringify(data,null,2);
        }
        ngModel.$parsers.push(into);
        ngModel.$formatters.push(out);
      }
    };
  });  

  w.directive("wf", function() {

    return {

      restrict: 'A',
      scope: { wf: "=" },
      templateUrl: "/workflow/diagram/workflow.html",

      link: function($scope,$element) {

        $scope.new_connection = function() {
          $scope.wf.specification.io.push({from: [0,"output"], to: [1,"input"]});
        }        

        $scope.delete_connection = function(connection) {
          aq.delete_from_array($scope.wf.specification.io,connection);
        }

        $scope.new_operation = function(connection) {
          $.ajax({
            url: "/operations/make.json"
          }).done(function(data) {
            var op = {
              x: 100, y: 100, id: data.id, operation: $.extend(data,{workflow: $scope.wf.id})
            };
            $scope.wf.specification.operations.push(op);
            $scope.$apply();
          });
        }

        $scope.save = function() {
          console.log(angular.toJson($scope.wf));
          $.ajax({
            method: "post",
            url: "/workflows/" + $scope.wf.id + "/save",
            contentType: 'application/json',
            dataType: 'json',
            data: angular.toJson($scope.wf)
          }).success(function(data) {
            console.log("saved");
            console.log(data);
          });
        }
      }
    }
  });        

})();
