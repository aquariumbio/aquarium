(function() {

  var w = angular.module('aquarium'); 

  w.directive("oplist", function() {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', operation_type: '=', jobid: '=' },
      replace: true,
      template: $('#operation-list').html()
    }

  });

})();