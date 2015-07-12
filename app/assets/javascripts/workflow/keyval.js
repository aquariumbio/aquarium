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
      scope: { keyval: "=", oper: "=", partType: "=" },
      templateUrl: "/workflow/editor/keyval.html",
      require: "^ngController",
      link: function($scope,$element,$attr,wfCtrl) {
        if ( $scope.$parent.$parent.h.operation.workflow != wfCtrl.get_id() ) {        
          $element.find('input').attr('disabled',true);
          $element.find('button').attr('disabled',true);
        }
      }
    }
  });     

})();