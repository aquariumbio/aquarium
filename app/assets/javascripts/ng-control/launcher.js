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
    $scope.plan = null;
    $scope.error = null;

    AQ.get_sample_names().then(() =>  {
      $scope.status = "Loading operation types ...";
      AQ.OperationType.all_with_content().then((operation_types) => {
        $scope.status = "Getting user information ...";
        AQ.User.current().then((user) => {
          $scope.status = "Retrieving plans ...";
          AQ.Plan.list().then((plans) => {
            $scope.status = "Ready";
            $scope.operation_types = operation_types;
            $scope.current_user = user;
            $scope.plans = plans.reverse();            
            $scope.mode = 'running';
            $scope.$apply();
          });
        });
      });
    });

    $scope.select = function(operation_type) {

      $scope.plan = AQ.Plan.record({
        operations: [ 
          AQ.Operation.record({
            routing: {},
            form: { input: {}, output: {} }
          }).set_type(operation_type)
        ]
      });

    }

    $scope.clear_plan = function() {
      $scope.plan = null;
    }

    $scope.submit_plan = function() {
      $scope.error = null;
      $scope.plan.submit().then((plan) => {
        $scope.clear_plan();
        $scope.mode = 'running';
        $scope.plans.unshift(plan);
        $scope.$apply();
      }).catch((error) => {
        $scope.error = error;
        $scope.$apply();
      });
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

    $scope.highlight = function(m) {
      var c = "";
      if ( m == $scope.mode ) {
        c += "highlight";
      }
      return c;
    }

  }]);

})();
