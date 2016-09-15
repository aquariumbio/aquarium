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

      ot.test_operations = null;

      $http.get("/operation_types/" + ot.id + "/random/" + ot.batch_size).then(function(response) {
        ot.test_operations = response.data;
        console.log(response.data)
      });

    }

    $scope.test = function(ot) {
      ot.test_results = null;
      $http.post("/operation_types/test", ot).then(function(response) {
        ot.test_results = response.data;
        ot.test_results.job.backtrace = JSON.parse(ot.test_results.job.state)
      });
    }

    $scope.content_type = function(line) {
      var type = Object.keys(line)[0];
      if ( type == "item") { console.log(type); }
      return type;
    }

    $scope.content_value = function(line) {
      var k = Object.keys(line)[0];
      return line[k];
    }     

  }]);

})();
