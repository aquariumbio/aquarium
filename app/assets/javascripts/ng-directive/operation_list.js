(function() {

  var w = angular.module('aquarium'); 

  w.directive("oplist", function() {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', ot: '=', jobid: '=' },
      replace: true,
      template: $('#operation-list').html()
    }

  });

})();