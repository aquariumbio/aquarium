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
      })
      .error(function() {
        console.log("Could not retrieve workflow");
      });

      $scope.clearSelection = function() {
        $scope.$root.selection = null;
      }

  });

  angular.forEach(['x', 'y', 'width', 'height', 'cx', 'cy', 'transform', 'd'], function(name) {
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
      link: function($scope) {
        $scope.new_connection = function() {
          $scope.wf.specification.io.push({from: [0,"output"], to: [1,"input"]});
        }        

        $scope.delete_connection = function(connection) {
          aq.delete_from_array($scope.wf.specification.io,connection);
        }    
      }
    }
  });        

})();
