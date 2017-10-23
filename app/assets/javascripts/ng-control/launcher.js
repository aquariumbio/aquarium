(function() {

  var w = angular.module('aquarium'); 

  w.controller('launcherCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', '$window',
                      function (  $scope,   $http,   $attrs,   $cookies,   $sce,   $window ) {

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
      user_info: "Loading",
      plans: "Loading"
    };

    $scope.state = { folder: "__NO_FOLDER_SELECTED__" };

    AQ.User.active_users().then(users => {

      $scope.users = users;

      AQ.User.current().then((user) => {

        $scope.current_user = user;
        $scope.status.user_info = "Ready";      
        $scope.getting_plans = true;    
        $scope.state.selected_user_id = $scope.current_user.id;  

        var plan_promise;

        if ( aq.url_params().plan_id ) {
          plan_promise =  AQ.Plan.list(0,$scope.current_user,$scope.state.folder,aq.url_params().plan_id);
          $scope.no_more_plans = true;
          $scope.single_plan_query = true;
          $scope.state.plan_id = aq.url_params().plan_id;          
          $window.history.replaceState(null, document.title, "/launcher"); 
        } else {
          plan_promise =  AQ.Plan.list($scope.plan_offset)
        }        

        plan_promise.then((plans) => {

          $scope.plans = plans.reverse();
          $scope.getting_plans = false;

          AQ.OperationType.all_with_field_types(true).then((operation_types) => {

            $scope.operation_types = aq.where(operation_types,ot => ot.deployed);
            AQ.OperationType.compute_categories($scope.operation_types);
            AQ.operation_types = $scope.operation_types;
            aq.each($scope.plans, (plan)=> { 
              plan.link_operation_types($scope.operation_types) 
            });

            AQ.Plan.get_folders().then(folders => {
              $scope.folders = folders;
              if ( !$scope.state.plan_id && !$scope.folders.includes($scope.state.folder) ) {
                $scope.state.folder = null;
              }

              $scope.status.plans = "Ready";
              $scope.$apply();

            });

          });

        });

      });

    });

    $scope.set_mode = function(m) {
      $scope.mode = m;
    }

    $scope.clear_error = function() {
      delete $scope.error;
    }

    $scope.more_plans = function() {
      $scope.plan_offset += 20;
      $scope.getting_plans = true;
      AQ.Plan.list($scope.plan_offset,$scope.current_user,$scope.state.folder).then((plans) => {
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

    $scope.select_folder = function(folder) {
      $scope.state.folder = folder;
      $scope.plan_offset = 0;
      $scope.getting_plans = true;
      $scope.no_more_plans = false;
      $scope.plans = [];
      AQ.Plan.list($scope.plan_offset,$scope.current_user,$scope.state.folder).then((plans) => {
        $scope.getting_plans = false;
        $scope.plans = plans.reverse();
        aq.each(plans, (plan)=> { plan.link_operation_types($scope.operation_types) });
        $scope.$apply();        
      });        
    }

    $scope.select_user = function() {

      AQ.User.find($scope.state.selected_user_id).then(user => {
        $scope.current_user = user;
        AQ.Plan.get_folders($scope.state.selected_user_id).then(folders => {
          $scope.state.folder = null;
          $scope.folders = folders;
          AQ.Plan.list($scope.plan_offset,$scope.current_user,$scope.state.folder).then((plans) => {
            $scope.plans = plans.reverse();        
            $scope.status.plans = "Ready";        
            $scope.getting_plans = false;        
            AQ.update();
          });
        });
      }).catch(data => {
        console.log("Could not find user " + $scope.state.selected_user_id);
        console.log(data)
      })

    }

    $scope.delete_plan = function(plan) {
      
      plan.deleting = true;
      AQ.http.delete("/plans/"+plan.id).then( () => {
        aq.remove($scope.plans,plan);
      })

    }   

    $scope.move = function(folder) {
      if ( $scope.state.folder != folder ) {
        var plans = aq.where($scope.plans, plan => plan.selected);
        AQ.Plan.move(plans, folder).then(() => {
          aq.each(plans, plan => {
            aq.remove($scope.plans, plan)
          })
        })
      }
    } 

    $scope.move_to_new = function() {
      var new_folder_name = window.prompt("New Folder Name");
      $scope.folders.push(new_folder_name);
      $scope.move(new_folder_name);
    }

    $scope.relaunch = function(plan) { // a.k.a. Copy

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

    $scope.plan_state_class = function(plan) {
      var c = "status";
      if ( plan.state == "Error" || plan.state == "Delayed" ) {
        c += " status-error";
      } else if ( plan.state == "Done" ) {
        c += " status-done";
      } else {
        c += " status-pending";
      }
      return c;
    }

    $scope.replan = function(plan) {
      plan.replan().then(newplan => {
        window.location = "/plans?plan_id=" + newplan.id;
      })
    }

  }]);

})();
