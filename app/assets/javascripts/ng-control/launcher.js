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
          $scope.select($scope.operation_types[5])
        });
      });
    });

    $scope.select = function(operation_type) {
      $scope.operation = new AQ.Record(AQ.Operation,{
        routing: {},
        form: { input: {}, output: {} }
      });
      $scope.operation.set_type(operation_type);
    }

    $scope.set_aft = function(op,ft,aft) {
      op.form[ft.role][ft.name] = { aft_id: aft.id, aft: aft };
      aq.each(op.field_values,function(fv) {
        if ( fv.name == fv.name && fv.role == ft.role ) {
          op.routing[ft.routing] = '';
          fv = { aft: aft, aft_id: aft.id, items: [] };
        }
      });
    }

  }]);

})();
