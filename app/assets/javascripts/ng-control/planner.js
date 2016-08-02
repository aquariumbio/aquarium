(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('plannerCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                     function (  $scope,   $http,   $attrs,   $cookies ) {

    $http.get('/operation_types.json').then(function(response) {
      $scope.operation_types = response.data;
    })

    $scope.browser_control_class = function(view) {
      var c = "browser-control";
      if ( $scope.views[view].selected ) {
        c += " browser-control-on";
      } 
      return c;
    }

    $scope.open = function(ot) {
      $scope.selection = ot;
    }

    $scope.close = function(ot) {
      $scope.selection = null;
    }

  }]);

})();