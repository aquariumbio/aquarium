(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('invoicesCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                      function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    $scope.status = {};

  }]);

})();