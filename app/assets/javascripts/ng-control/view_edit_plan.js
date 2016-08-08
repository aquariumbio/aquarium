(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('viewEditPlanCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                       function (  $scope,   $http,   $attrs,   $cookies ) {


    $scope.plan = function(ot) {
      // ot.mode = 'waiting';
      $http.post("/operations/plan",{ ot_id: ot.id, operations: ot.operations }).then(function(response) {
        ot.plan = response.data.plan;
        ot.trees = response.data.trees;
        ot.current = response.data.trees[0];
        ot.issues = response.data.issues;
        ot.mode = 'plan';
      });
    }

    $scope.node_class = function(ot,node) {
      var c = "node";
      if ( ot.current == node ) {
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

  }]);

})();