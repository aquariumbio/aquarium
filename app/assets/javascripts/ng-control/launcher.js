(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('launcherCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                      function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }
    AQ.sce = $sce;

    $scope.plan = null;
    $scope.error = null;
    $scope.plan_offset = 0;
    $scope.getting_plans = false;
    $scope.mode = 'running';

    $scope.status = {
      sample_names: "Loading",
      operation_types: "Loading",
      user_info: "Loading",
      plans: "Loading"
    }

    AQ.User.current().then((user) => {

      $scope.current_user = user;
      $scope.status.user_info = "Ready";      
      $scope.getting_plans = true;      

      AQ.Plan.list($scope.plan_offset).then((plans) => {

        $scope.plans = plans.reverse();        
        $scope.status.plans = "Ready";        
        $scope.getting_plans = false;

        AQ.OperationType.all_with_content().then((operation_types) => {

          $scope.operation_types = aq.where(operation_types,ot => ot.deployed);
          AQ.OperationType.compute_categories($scope.operation_types);
          AQ.operation_types = $scope.operation_types;
          aq.each($scope.plans, (plan)=> { 
            plan.link_operation_types($scope.operation_types) 
          });       

          $scope.status.operation_types = "Ready";

          AQ.get_sample_names().then(() =>  {
            $scope.status.sample_names = "Ready";
          });

          $scope.$apply();

        });
      });
    });

    $scope.set_mode = function(m) {
      $scope.mode = m;
    }

    $scope.clear_error = function() {
      delete $scope.error;
    }

    $scope.io_focus = function(op,ft,fv) {
      $scope.current_operation = op;
      $scope.current_fv = fv;
      $scope.current_ft = ft;
      delete $scope.plan.status;
      aq.each($scope.plan.wires, w => {
        aq.each(w.to_op.field_values, field_value => { 
          field_value.selected = false;
        })
        aq.each(w.from_op.field_values, field_value => { 
          field_value.selected = false;
        })
      })
      fv.selected = true;
    }

    $scope.io_blur = function() {
      $scope.current_operation = null;
      $scope.current_fv = null;
      $scope.current_ft = null;  
    }

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

    $scope.select_uba= function(user,s) {      
      aq.each(user.user_budget_associations, uba => {
        if ( uba.id == s.id ) {
          uba.selected = true;
          $scope.plan.uba = uba;
        } else {
          uba.selected = false;
        }
      });
    }

    $scope.unselect_ubas = function(user) {
      aq.each(user.user_budget_associations, uba => {
        if ( $scope.plan ) {
          $scope.plan.uba = null;
        }
        uba.selected = false;
      });
    }

    $scope.remove_operation = function(op) {
      aq.remove($scope.plan.operations,op);
      if ( $scope.plan.operations.length == 0 ) {
        $scope.plan = null;
        $scope.unselect_ubas($scope.current_user);
      }
      $scope.current_operation = null;
    }

    $scope.add_goal = function() {
      aq.each($scope.plan.operations,op => op.closed = true)
      $scope.plan.operations.unshift(
        AQ.Operation.record({
            routing: {},
            form: { input: {}, output: {} }
          }).set_type($scope.plan.operations[0].operation_type)
      )
      $scope.io_blur();
    }

    $scope.submit_plan = function() {
      $scope.error = null;
      $scope.plan.status = 'planning';
      $scope.plan.submit().then((plan) => {
        $scope.plan = null;
        $scope.unselect_ubas($scope.current_user);
        $scope.current_operation = null;
        $scope.mode = 'running';
        plan.link_operation_types($scope.operation_types);
        $scope.plans.unshift(plan);
        aq.each($scope.plans,plan => plan.open = false);
        plan.open = true;
        aq.each(plan.operations,op => op.open = false);
        $scope.$apply();
      }).catch((error) => {
        console.log(error)
        delete $scope.plan.status;
        $scope.error = error;
        $scope.$apply();
      });
    }

    $scope.relaunch = function(plan) {

      plan.relaunching = true;

      plan.relaunch().then( (newplan,issues) => {
        newplan.link_operation_types($scope.operation_types);
        $scope.plans.unshift(newplan);
        newplan.open = true;
        plan.open = false;
        delete plan.relaunching;
        $scope.$apply();
      }).catch( ()=> {console.log("oops")});

    }

    $scope.op_mode = function(op,m) {
      var c = "btn btn-mini";
      if ( op.mode == m ) {
        c += " btn-primary";
      }
      return c;
    }

    $scope.more_plans = function() {
      $scope.plan_offset += 15;
      $scope.getting_plans = true;
      AQ.Plan.list($scope.plan_offset).then((plans) => {
        if ( plans.length == 0 ) {
          $scope.no_more_plans = true;
        } else {
          $scope.getting_plans = false;
          $scope.plans = $scope.plans.concat(plans.reverse());
          aq.each(plans, (plan)=> { plan.link_operation_types($scope.operation_types) });
        }
        $scope.$apply();        
      });      
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

    $scope.select_item = function(fv, item) {
      aq.each(fv.items, i => {
        if ( i.collection ) {
          i.selected = (i.collection.id == item.collection.id);
        } else {
          i.selected = (i.id == item.id);        
        }
        console.log((i.id || i.collection.id) + ": " + i.selected);
      });
      fv.selected_item = item;
    }

    $scope.select_row_column = function(fv,element,item,r,c) {
      if ( fv.sid == element ) {
        item.selected_row = r;
        item.selected_column = c;
      }
    }

    $scope.set_current_op = function(op) {
      $scope.current_operation = op;
      $scope.current_fv = null;
    }

  }]);

})();
