(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('viewEditPlanCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                       function (  $scope,   $http,   $attrs,   $cookies ) {


    $scope.node_class = function(plan,node) {
      var c = "node";
      if ( plan.current_node == node ) {
        c += " node-selected";
      } 
      if ( node.ready ) {
        c += " node-ready";
      }
      if ( node.status == 'unplanned' ) {
        c += " node-unplanned";
      }
      if ( node.problem ) {
        c += " node-problem";
      }
      return c;
    }

    $scope.select_node = function(plan,node) {
      plan.current_node = node;
    }    

  }]);

})();