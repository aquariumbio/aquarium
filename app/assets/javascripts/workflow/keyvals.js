
(function() {

  var w;
  try {
    w = angular.module('workflow_editor'); 
  } catch (e) {
    w = angular.module('workflow_editor', []); 
  } 

  w.directive("keyvals", function() {

    return {

      restrict: 'A',
      scope: { keyvals: "=" },
      templateUrl: "/workflow_editor/keyvals.html",

      link: function($scope,element,attrs) {

        $scope.new_keyval = function() {
          $scope.keyvals.push({"name": "", "type": ""});
        }        

        $scope.delete_keyval = function(kv) {
          aq.delete_from_array($scope.keyvals,kv);
        }    

      }

    }

  });  

})();

