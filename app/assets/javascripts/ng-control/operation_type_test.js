(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('operationTypeTestCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                              function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.randomize = function(ot) {

      if ( !ot.batch_size ) {
        ot.batch_size = 1;
      }

      $http.get("/operation_types/" + ot.id + "/random/" + ot.batch_size).then(function(response) {
        ot.test_operations = response.data;
      });

    }

  }]);

})();
