(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.directive("oplist", function() {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', ot: '=', jobid: '=' },
      replace: true,
      template: $('#operation-list').html()
    }

  });

})();