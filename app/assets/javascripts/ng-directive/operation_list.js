(function() {

  var w = angular.module('aquarium'); 

  w.directive("oplist", function() {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', operationtype: '=', jobid: '=' },
      replace: true,
      template: $('#operation-list').html()
    }

  });

  w.directive("oplistShort", function() {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', operationtype: '=', jobid: '=' },
      replace: true,
      template: $('#operation-list-short').html(),
      link: function($scope,$element,$attributes) {

        $scope.open_item_ui = function(id) {
          open_item_ui(id)
        }

      }      
    }

  });  

})();