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
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.status = "Loading sample names ...";
    $scope.plan = null;
    $scope.error = null;
    $scope.plan_offset = 0;
    $scope.getting_plans = false;

    $scope.io_focus = function(op,ft,fv) {
      $scope.current_operation = op;
      $scope.current_fv = fv;
      $scope.current_ft = ft;
    }

    AQ.get_sample_names().then(() =>  {
      $scope.status = "Loading operation types ...";
      AQ.OperationType.all_with_content().then((operation_types) => {
        $scope.status = "Getting user information ...";
        AQ.User.current().then((user) => {
          $scope.status = "Retrieving plans ...";
          $scope.getting_plans = true;
          AQ.Plan.list($scope.plan_offset).then((plans) => {
            $scope.status = "Ready";
            $scope.getting_plans = false;
            AQ.operation_types = operation_types;
            $scope.operation_types = operation_types;

            // FOR DEVELOPING LAUNCHER, DELETE LATER
            $scope.select(operation_types[2]);
            $scope.mode = 'new';

            $scope.current_user = user;
            $scope.plans = plans.reverse();
            aq.each($scope.plans, (plan)=> { plan.link_operation_types($scope.operation_types) });
            // $scope.mode = 'running';
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
        plan.link_operation_types($scope.operation_types);
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
        if ( fv.name == ft.name && fv.role == ft.role ) {
          op.routing[ft.routing] = '';
          fv.aft = aft;
          fv.aft_id = aft.id;
          fv.items = [];
          fv.field_type = ft;
          fv.recompute_getter('predecessors');
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

    $scope.op_mode = function(op,m) {
      var c = "btn btn-mini";
      if ( op.mode == m ) {
        c += " btn-primary";
      }
      return c;
    }

    $scope.inc_plan_offset = function(dir) {
      if ( $scope.more_plans(dir) ) {
        $scope.plan_offset += 15 * dir;
        $scope.getting_plans = true;
        AQ.Plan.list($scope.plan_offset).then((plans) => {
          $scope.getting_plans = false;
          $scope.plans = plans.reverse();
          aq.each($scope.plans, (plan)=> { plan.link_operation_types($scope.operation_types) });
          $scope.$apply();
        });      
      } 
    }

    $scope.more_plans = function(dir) {
      var o = $scope.plan_offset + 15 * dir; 
      return o >= 0 && o < AQ.Plan.num_plans;
    }

    $scope.choose_default_part = function(fv,item) {
      if ( item.collection ) {
      // used in _field_value_editor.html.erb to initialized collection choice
        for ( var r=0; r<item.collection.matrix.length; r++ ) {
          for ( var c=0; c<item.collection.matrix[r].length; c++ ) {
            if ( item.collection.matrix[r][c] == fv.sid ) {
              item.selected_row = r;
              item.selected_column = c;
            }
          }
        }
      }
    }

  }]);

})();
