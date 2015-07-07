(function() {

  var w;
  try {
    w = angular.module('workflow'); 
  } catch (e) {
    w = angular.module('workflow', []); 
  } 

  w.directive("keyval", function() {
    return {
      restrict: 'A',
      scope: { keyval: "=", opName: "=", opType: "=" },
      templateUrl: "/workflow/editor/keyval.html"
    }
  });     

})();