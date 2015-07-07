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

    this.get_id = function() { return $scope.workflow.id };

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
            $scope.wf.specification.operations.push({
              x: 100, y: 100, id: data.id, operation: $.extend(data,{workflow: $scope.wf.id})
            });
            $scope.$apply();
          });
        }

        $scope.save = function() {
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
