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
          // $scope.select($scope.operation_types[3])
        });
      });
    });

    $scope.select = function(operation_type) {
      $scope.operation = new AQ.Record(AQ.Operation,{
        input: {},
        output: {},
        routing: {}
      });
      $scope.operation.set_type(operation_type);
    }

    $scope.set_aft = function(op,ft,aft) {
      op[ft.role][ft.name].aft = aft;
      op.routing[ft.routing] = '';
      op[ft.role][ft.name] = { aft: aft, aft_id: aft.id, items: [] };
    }

  }]);

})();
