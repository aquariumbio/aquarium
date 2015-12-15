(function() {

  w = angular.module('process_viewer',[]);

  w.controller('pvCtrl', [ '$scope', '$http', '$attrs', function ($scope,$http,$attrs) {

    $scope.active = [];
    $scope.recent = [];

    $scope.category = "active";
    $scope.days_ago = 1;
    $scope.users = [];

    $http.get('/users.json')
      .success(function(users) {
        angular.forEach(users,function(u) {
          $scope.users[u.id] = u;
        })
      })
      .error(function() {
        console.log("Could not retrieve users");
      });

    $scope.activeOn = function() {
      $scope.category = 'active';
      if ( $scope.active.length > 0 ) {
        $scope.selection = $scope.active[0];
      }
    }

    $scope.recentOn = function() {
      $scope.category = 'recent';
      if ( $scope.recent.length > 0 ) {
        $scope.selection = $scope.recent[0];
      }      
    }

    $scope.get_active = function() {
      $scope.active_loading = true;
      $http.get('/workflow_processes/active.json')
        .success(function(procs) {
          $scope.active = procs;
          $scope.active_loading = false;   
          $scope.activeOn();                 
        })
        .error(function() {
          console.log("Could not retrieve active processes");
        });
    }

    $scope.get_recent = function() {
      $scope.recent_loading = true;
      $http.get('/workflow_processes/recent.json?days_ago=' + $scope.days_ago)
        .success(function(procs) {
          $scope.recent = procs;
          $scope.recent_loading = false;          
        })
        .error(function() {
          console.log("Could not retrieve recent processes");
        });      
    }

    $scope.get_active();
    $scope.get_recent();

    $scope.incrementDaysAgo = function() {
      $scope.days_ago += 1;
      $scope.recent = [];
      $scope.get_recent();
    }    

    $scope.decrementDaysAgo = function() {
      if ( $scope.days_ago > 1 ) {
        $scope.days_ago -= 1;
        $scope.recent = [];
        $scope.get_recent();
      }
    }    

    $scope.select = function(p) {
      $scope.selection = p;
    }

    $scope.job = function(process,jid) {
      var jb = null;
      angular.forEach(process.jobs,function(j) {
        if ( parseInt(j.id) == jid ) {
          jb = j;
        }
      });
      return jb;
    }

    $scope.check_status = function(process,jid,f) {
      var j = $scope.job(process,jid);
      if ( j ) {
        return f(j.pc);
      } else {
        return false;
      }
    }

    $scope.is_completed = function(job) {
      return job && job.pc == -2;
    }    

    $scope.is_pending = function(job) {
      return job && job.pc == -1;
    }

    $scope.is_active = function(job) {
      return job && job.pc >= 0;
    }       

    $scope.jobless = function(jid) {
      return !jid;
    }

    $scope.is_today = function(date) {
      var today = new Date();
      var other = new Date(date);
      return today.toDateString() == other.toDateString();
    }

    $scope.has_error = function(job) {
      if ( job ) {
        var bt = JSON.parse(job.state);
        var n = bt.length;
        return $scope.is_completed(job) && bt[n-1].operation != "complete";
      } else {
        return false;
      }
    }

    $scope.operation_name_class = function(job) {
      if ( !job ) {
        return "operation-name no-job";
      } else if ( $scope.is_completed(job) ) {
        return "operation-name";
      } else if ( $scope.is_active(job) ) {
        return "operation-name active blinking";
      } else if ( $scope.is_pending(job) ) {
        return "operation-name pending";
      } else {
        return "";
      }
    }

    $scope.kill = function(process) {
      if ( confirm("Are you sure you want to kill process " + process.id + " and all of its associated jobs?") ) {
        $http.get('/workflow_processes/kill/'+process.id)
          .success(function(result) {
            var n = $scope.active.indexOf(process);
            if ( n>=0 ) {
              $scope.active.splice(n,1);
              $scope.recent.unshift(result.process);
              $scope.selection = result.process;
              // $scope.category = "recent";
              $scope.activeOn();

            }
            console.log("killed process " + process.id);
          });
      }
    }

    $scope.info = function(ops,oc) {
      var b = oc.show_info;
      angular.forEach(ops,function(oc) { oc.show_info = false; })
      oc.show_info = !b;
    }

  }]);

})();