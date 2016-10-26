(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('plannerCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                     function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {                  

    $scope.plans = [];
    $scope.mode = 'main';
    $scope.ready = false;
    $scope.current_plan = null;
    $scope.goal = null;
    $scope.build_errors = [];

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
      if ( aq.query().id ) {
         var id = parseInt(aq.query().id);
         var plans = aq.where($scope.plans, function(p) { return p.id == id; });
         if ( plans.length == 1 ) {
           $scope.select_plan(plans[0]);
         }
      } else if ( $scope.plans.length > 0 ) {
        $scope.select_plan($scope.plans[0]);
      }
    })

    $scope.operation_type = function(node) {
      var m = aq.where($scope.operation_types,function(ot) {
        return ot.id == node.operation_type_id;
      });
      return m[0];
    }  

    $scope.operation = function(node) {
      var m = aq.where($scope.current_plan.operations,function(o) {
        return o.id == node.id;
      });
      return m[0];      
    }

    $scope.launch = function(plan) {
      plan.launch_mode = "Launching";
      $http.get("/plans/start/" + plan.id).then(function(response) {
        var index = $scope.plans.indexOf(plan);
        $scope.plans[index] = response.data.plan;
        if ( $scope.current_plan.id == response.data.plan.id ) {
          $scope.current_plan = response.data.plan;
          $scope.current_plan.issues = response.data.issues;
        }
      });
    }

    $scope.plan = function(ot) {
      $http.post("/plans/plan",{ ot_id: ot.id, operations: ot.operations }).then(function(response) {
        if ( response.data.errors ) {
          $scope.build_errors = response.data.errors;
          console.log(response.data.errors);
        } else {
          $scope.build_errors = [];
          $scope.mode = 'view';
          $scope.plans.unshift(response.data);
          $scope.current_plan = response.data;
          ot.operations = null;
        }
      });
    }      

    $scope.replan = function(op) {
      $http.post("/plans/replan", op).then(function(response) {
        var i = $scope.plans.indexOf(op);
        $scope.mode = 'view';
        $scope.plans[i] = response.data;
        $scope.current_plan = response.data;
      });
    }

    function promote_data_op(op) {
      PromoteDataAssociations(op);
      aq.each(op.predecessors,function(p) {
        aq.each(p.operations, function(op) {
          promote_data_op(op);
        })
      })
    }

    function promote_data(plan) {
      aq.each(plan.goals,function(goal) {
        promote_data_op(goal);
      })
    }

    $scope.select_plan = function(plan) {

      $scope.current_plan = plan;
      $scope.mode = 'view';

      if ( !plan.trees ) {
        $http.get('/plans/'+plan.id+'.json').then(function(response) {
          var index = $scope.plans.indexOf(plan);
          $scope.plans[index] = response.data;
          $scope.plans[index].http = $http;
          promote_data($scope.plans[index]);
          if ( $scope.current_plan.id == $scope.plans[index].id ) {
            $scope.current_plan = $scope.plans[index];
          }
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
        ot.operations = [ empty_goal(ot) ];
      }

      $scope.mode = 'build';
      $scope.goal = ot;
      var md = window.markdownit();
      ot.rendered_docs = $sce.trustAsHtml(md.render(ot.documentation.content));
    }

    $scope.close_goal = function(ot) {
      $scope.goal = null;
    }    

    $scope.select_predecessor = function(plan,op,ops) {
      // plan.issues = [ { msg: "Note: Editing plans is not yet implemented." } ];
      $http.get("/plans/" + plan.id + "/select/" + op.id ).then(function(response) {
        var index = $scope.plans.indexOf(plan);
        $scope.plans[index] = response.data;
        $scope.plans[index].http = $http;
        promote_data($scope.plans[index]);
        if ( $scope.current_plan.id == $scope.plans[index].id ) {
          $scope.current_plan = $scope.plans[index];
        }
      });
    }    

  }]);

})();