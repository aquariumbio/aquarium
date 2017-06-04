
(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('operationsCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                        function (  $scope,   $http,   $attrs,   $cookies ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.operation_types = [];

    function category_index(c) {
      $scope.categories.indexOf(c);
    }

    function init() {

      if ( $cookies.getObject("managerState") ) {
        $scope.current = $cookies.getObject("managerState");
        if ( $scope.current.ot != null && $scope.current.status != null ) {
          var ot = aq.find(AQ.operation_types, ot => ot.id == $scope.current.ot.id);
          $scope.current.category_index = $scope.categories.indexOf(ot.category);
          $scope.select(ot,$scope.current.status,[]);
        }       
      } else {
        $scope.current = {
          ot: null,
          status: null,
          category_index: 0
        }
      }

    }

    $scope.status = 'Loading Operation Types ...';
    AQ.OperationType.where({deployed: true}).then(operation_types => {
      $scope.status = "Fetching user information ...";
      AQ.User.current().then( user => {
        AQ.OperationType.numbers().then(numbers => {
          $scope.status = "Ready";
          AQ.operation_types = operation_types;
          $scope.operation_types = operation_types;
          aq.each($scope.operation_types,ot => { 
            ot.list = {
              done: { offset: 0, limit: 10 },
              error: { offset: 0, limit: 10 }
            }
          });
          $scope.categories = aq.uniq(aq.collect(operation_types, ot => ot.category)).sort();
          $scope.current_user = user;
          $scope.numbers = numbers;
          init();
          $scope.$apply();
        });
      });
    });

    $scope.status_selector = function(ot,status) {
      var c = "";
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
      return c;
    }

    $scope.select = function(ot,status,selected_ops,append=false) {

      $scope.current.ot = ot; 
      $scope.current.status = status;
      $scope.current.category_index = $scope.categories.indexOf(ot.category);

      $cookies.putObject("managerState", $scope.current);

      if ( !append ) {
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
        console.log([status,options])
      } else {
        options = {};
      }

      AQ.Operation.where({
        operation_type_id: ot.id, 
        status: actual_status
      },{
        methods: ['user','field_values', 'precondition_value', 'plans', 'jobs']
      },options).then(operations => {
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
        $scope.$apply();
      })

    }

    $scope.more = function(status) {
      $scope.current.ot.list[status].offset += 10;
      $scope.select($scope.current.ot,status,[],true);
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
          AQ.OperationType.numbers().then(numbers => {
            $scope.numbers = numbers;
            $scope.select(ot,'scheduled',ops);
            $scope.$apply();
          });
        });
      }

    }

    $scope.unschedule = function(ot,jid) {

      var ops = aq.where(ot.operations,op => op.selected && op.last_jobs.id == jid);

      if ( ops.length > 0 ) {     
        ot.unschedule(ops).then( () => { 
          AQ.OperationType.numbers().then(numbers => {
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
        AQ.OperationType.numbers().then(numbers => {
          $scope.numbers = numbers;
          aq.remove($scope.jobs,job_id);
          delete $scope.debugging_job_id;
          $scope.$apply();
        });
      })

    }

  }]);

})();
