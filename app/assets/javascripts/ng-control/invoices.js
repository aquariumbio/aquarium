(function() {

  var w = angular.module('aquarium'); 
  
  w.controller('invoicesCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                      function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    $scope.status = {};

  }]);

})();