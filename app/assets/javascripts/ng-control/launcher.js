(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('launcherCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                      function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    AQ.init($http);

    $scope.status = "Loading sample names ...";

    AQ.get_sample_names().then(() =>  {
      $scope.status = "Loading operation types ...";
      AQ.OperationType.all_with_content().then((operation_types) => {
        $scope.status = "Determining current user ...";
        AQ.User.current().then((user) => {
          $scope.status = "ready";
          $scope.operation_types = operation_types;
          $scope.current_user = user;
        });
      });
    });

    $scope.select = function(operation_type) {
      $scope.operation = new AQ.Record(AQ.Operation,{
        field_values: []
      });
      $scope.operation.set_type(operation_type);
    }

  }]);

})();
