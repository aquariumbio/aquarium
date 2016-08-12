(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('plannerCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                     function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.plans = [];
    $scope.mode = 'main';
    $scope.ready = false;
    $scope.current_plan = null;
    $scope.goal = null;

    $scope.helper = new SampleHelper($http);

    $scope.helper.autocomplete(function(sample_names) {
      $scope.$root.sample_names = sample_names;
    });

    $http.get('/operation_types.json').then(function(response) {
      $scope.operation_types = response.data;
    })

    $http.get('/plans.json').then(function(response) {
      $scope.plans = response.data;
      $scope.ready = true;      
    })

    $scope.operation_type = function(operation) {
      var m = aq.where($scope.operation_types,function(ot) {
        return ot.id == operation.operation_type_id;
      });
      return m[0];
    }  

    function determine_launch_mode(plan) {
      var op = plan.operations[0];
      if ( op.status == 'planning' ) {
        plan.launch_mode = 'Launch';
      } else {
        plan.launch_mode = "Stop";
      }      
    }

    $scope.launch = function(plan) {
      plan.launch_mode = "Launching";
      $http.get("/plans/start/" + plan.id).then(function(response) {
        var index = $scope.plans.indexOf(plan);
        $scope.plans[index] = response.data;
        $scope.plans[index].current_node = response.data.trees[0];
        if ( $scope.current_plan.id == response.data.id ) {
          $scope.current_plan = response.data;
        }
        determine_launch_mode($scope.current_plan);
      });
    }

    $scope.plan = function(ot) {
      $http.post("/plans/plan",{ ot_id: ot.id, operations: ot.operations }).then(function(response) {
        $scope.mode = 'view';
        $scope.plans.unshift(response.data);
        $scope.current_plan = response.data;
        $scope.current_plan.current_node = response.data.trees[0];
        var op = response.data.operations[0];
        determine_launch_mode($scope.current_plan);
      });
    }      

    $scope.select_plan = function(plan) {

      $scope.current_plan = plan;
      $scope.mode = 'view';

      if ( !plan.trees ) {
        $http.get('/plans/'+plan.id+'.json').then(function(response) {
          var index = $scope.plans.indexOf(plan);
          $scope.plans[index] = response.data;
          $scope.plans[index].current_node = response.data.trees[0];
          if ( $scope.current_plan.id == response.data.id ) {
            $scope.current_plan = response.data;
          }
          determine_launch_mode($scope.current_plan);
        });
      }

    }

    $scope.delete_plan = function(plan) {
      $http.delete('/plans/'+plan.id).then(function(response) {
        var index = $scope.plans.indexOf(plan);
        $scope.plans.splice(index,1);
        $scope.mode = 'main';
      });     
    }

    $scope.plan_choice_class = function(p) {
      var c = "";
      if ( $scope.current_plan == p ) {
        c += "plan-choice-selected";
      }
      return c;
    }

    $scope.set_mode = function(m) {
      $scope.mode = 'choose';
    }

    $scope.open_goal = function(ot) {
      if ( !ot.operations ) {
        ot.operations = [ { fvs: {} } ];
      }
      $scope.mode = 'build';
      $scope.goal = ot;
    }

    $scope.close_goal = function(ot) {
      $scope.goal = null;
    }

  }]);

})();