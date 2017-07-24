
(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('operationsCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$interval', 
                        function (  $scope,   $http,   $attrs,   $cookies,   $interval ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.operation_types = [];

    function category_index(c) {
      $scope.categories.indexOf(c);
    }

    function init1() {

      if ( false || $cookies.getObject("managerState") ) {

        $scope.current = $cookies.getObject("managerState");

        if ( $scope.current.selected_user ) {
          $scope.current.selected_user = AQ.User.record({
            id: $scope.current.selected_user.id, 
            name: $scope.current.selected_user.name, 
            login: $scope.current.selected_user.login,
          })
        }
      
      } else {
        $scope.current = {
          ot: null,
          status: null,
          category_index: 0,
          show_completed: false,
          filter_user: false,
          selected_user: null
        }
      }

      $interval(reload, 30000);

    }

    function init2() {
      if ( $scope.current.ot != null && $scope.current.status != null ) {
        var ot = aq.find(AQ.operation_types, ot => ot.id == $scope.current.ot.id);
        if ( ot ) {
          $scope.current.category_index = $scope.categories.indexOf(ot.category);
          $scope.select(ot,$scope.current.status,[]);
        } else {
          $scope.current.category_index = 0;
        }
      }       
    }

    function get_numbers() {
      return AQ.OperationType.numbers($scope.current.selected_user,$scope.current.filter_user)      
    }    

    init1();

    $scope.status = 'Loading Operation Types ...';

    AQ.OperationType.where({deployed: true},{methods: ["timing"]}).then(operation_types => {
      $scope.status = "Fetching user information ...";
      AQ.User.current().then( user => {
        AQ.User.active_users().then(users => {
          $scope.users = users;
          get_numbers().then(numbers => { 

            $scope.status = "Ready";
            AQ.operation_types = AQ.OperationType.sort_by_timing(operation_types);
            $scope.operation_types = AQ.operation_types;
            aq.each($scope.operation_types,ot => { 
              ot.list = {
                done: { offset: 0, limit: 10 },
                error: { offset: 0, limit: 10 }
              };
              ot.timing = AQ.Timing.record(ot.timing);
            });
            $scope.categories = aq.uniq(aq.collect(operation_types, ot => ot.category)).sort();
            $scope.current_user = user;
            $scope.numbers = numbers;            
            $scope.$apply();
            init2();

          });
        });
      });
    });

    $scope.status_selector = function(ot,status) {
      var c = "";
      if ( $scope.numbers[ot.id] ) {
        if ( status == 'waiting' && $scope.numbers[ot.id]['waiting'] + $scope.numbers[ot.id]['pending_false'] != 0 ) {
          c += " number-some";
        } else if ( $scope.numbers[ot.id][status] == 0 ) {
          c += " number-none";
        } else {
          c += " number-some";
        }
        if ( $scope.current.ot == ot && $scope.current.status == status ) {
          c += " number-selected"
        } else {
          c += " number";
        }
      }
      return c;
    }

    function store_cookie() {
      $cookies.putObject("managerState", {
        ot: { id: $scope.current.ot.id },
        status: $scope.current.status,
        category_index: $scope.current.category_index,
        show_completed: $scope.current.show_completed,
        selected_user: $scope.current.selected_user,
        filter_user: $scope.current.filter_user
      });          
    }

    $scope.select = function(ot,status,selected_ops,append=false) {

      if ( !append ) {
        $scope.current.ot = ot; 
        $scope.current.status = status;
        $scope.current.category_index = $scope.categories.indexOf(ot.category);
        store_cookie();
        delete ot.operations;
      }
      delete $scope.jobs;

      var actual_status, options;

      if ( status == 'pending_true' ) {
        actual_status = 'pending';
      } else if ( status == 'waiting' ) {
        actual_status = ['pending','waiting'];
      } else {
        actual_status = status;
      }

      if ( status == "error" || status == "done" ) {
        options = { offset: ot.list[status].offset, limit: ot.list[status].limit, reverse: true };
      } else {
        options = {};
      }

      var criteria = { 
        operation_type_id: ot.id, 
        status: actual_status
      };

      if ( $scope.current.filter_user && $scope.current.selected_user ) {
        criteria.user_id = $scope.current.selected_user.id
      } else if ( !$scope.current_user.is_admin ) {
        criteria.user_id = $scope.current_user.id;
      }

      AQ.Operation.where(criteria,{
        methods: ['user','field_values', 'precondition_value', 'plans', 'jobs']
      },options).then(operations => {
        aq.each(operations,op => {
          op.jobs = aq.collect(op.jobs, job => AQ.Job.record(job));
          op.field_values = aq.collect(op.field_values, fv => AQ.FieldValue.record(fv))
        });
        if ( status == 'waiting' ) {
          ot.operations = aq.where(operations, op => { return (op.status == 'pending' && !op.precondition_value) || op.status == 'waiting' });
        } else if ( status == 'pending_true' ) {
          ot.operations = aq.where(operations, op => op.status == "pending" && op.precondition_value);
        } else {
          if ( append ) {
            ot.operations = ot.operations.concat(operations);
          } else {
            ot.operations = operations;
          }
        }
        aq.each(ot.operations, op => { 
          aq.each(selected_ops, sop => {
            if ( op.id == sop.id ) {
              op.selected = true;
            }
          })
        })
        $scope.jobs = aq.uniq(aq.collect(ot.operations,op => {
          return op.jobs.length > 0 ? op.last_job.id : null
        }));
        $scope.applying_user_filter = false;
        $scope.$apply();
      })

    }

    $scope.more = function(status) {
      $scope.current.ot.list[status].offset += 10;
      $scope.select($scope.current.ot,status,[],true);
    }

    function reload() {

      var old_val;

      if ( $scope.numbers[$scope.current.ot.id] ) {
        old_val = $scope.numbers[$scope.current.ot.id][$scope.current.status];
      }

      get_numbers().then(numbers => {
        $scope.numbers = numbers;
        if ( $scope.numbers[$scope.current.ot.id] && old_val != $scope.numbers[$scope.current.ot.id][$scope.current.status] ) {
          $scope.select($scope.current.ot, $scope.current.status,[])
        }
        $scope.$apply();
      });

    }

    $scope.choose = function(ot,status,val,job_id) {
      aq.each(ot.operations, op => {
        if ( op.operation_type_id == ot.id && op.status == status && ( !job_id || op.last_job.id == job_id )) {
          op.selected = val;
        }
      });
    }

    $scope.batch = function(ot) {

      var ops = aq.where(ot.operations, op => op.selected);

      if ( ops.length > 0 ) {
        ot.schedule(ops).then( () => {
          get_numbers().then(numbers => { 
            $scope.numbers = numbers;
            $scope.select(ot,'scheduled',ops);
            $scope.$apply();
          });
        });
      }

    }

    $scope.retry = function(ot) {

      var ops = aq.where(ot.operations, op => op.selected);

      aq.each(ops, op => {
        op.set_status("pending").then( op => {
          get_numbers().then(numbers => { 
            $scope.numbers = numbers;
            $scope.select(ot,'pending',ops);
            $scope.$apply();
          });
        });
      });

    }    

    $scope.unschedule = function(ot,jid) {

      var ops = aq.where(ot.operations,op => op.selected && op.last_jobs.id == jid);

      if ( ops.length > 0 ) {     
        ot.unschedule(ops).then( () => { 
          get_numbers().then(numbers => {
            $scope.numbers = numbers;
            $scope.select(ot,'pending_true',ops);    
            $scope.$apply();
          });
        });
      } 

    }

    $scope.debug = function(ot,job_id) {

      $scope.debugging_job_id = job_id;

      var num = aq.where(ot.operations, op => op.last_job.id == job_id).length;

      $http.get("/krill/debug/" + job_id).then(response => {
        get_numbers().then(numbers => { 
          $scope.numbers = numbers;
          aq.remove($scope.jobs,job_id);
          delete $scope.debugging_job_id;
          $scope.$apply();
        });
      })

    }

    $scope.timing_bullet = function(ot) {
      if ( ot.timing ) {
        return 'timing-bullet-' + ot.timing.status;
      } else {
        return 'timing-bullet-none';
      }
    }

    $scope.select_user = function() {
      store_cookie();
      $scope.applying_user_filter = true;
      reload();
    }

  }]);

})();
