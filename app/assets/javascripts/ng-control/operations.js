
(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('operationsCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                        function (  $scope,   $http,   $attrs,   $cookies ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    $scope.operation_types = [];

    $scope.current = {
      ot: null,
      status: null
    }

    $scope.status = 'Loading Operation Types ...';
    AQ.OperationType.all_with_content().then(operation_types => {
      $scope.status = "Fetching user information ...";
      AQ.User.current().then( user => {
          $scope.status = "Ready";
          AQ.operation_types = operation_types;
          $scope.operation_types = operation_types;
          $scope.current_user = user;
          $scope.$apply();
      });
    });

    $scope.show_operation_type = function() {
      return function(ot) {
        var s = 0;
        for ( key in ot.numbers ) {
          s += ot.numbers[key];
        }
        return s != 0;
      }
    }

    $scope.status_selector = function(ot,status) {
      var c = "";
      if ( ot.numbers[status] == 0 ) {
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

    $scope.select = function(ot,status,selected_ops) {

      $scope.current.ot = ot; 
      $scope.current.status = status;

      var actual_status = ( status == 'pending_true' || status == 'pending_false' ? 'pending' : status );

      AQ.Operation.where({
        operation_type_id: ot.id, 
        status: actual_status
      },{
        methods: ['user','field_values', 'precondition_value', 'plans']
      }).then(operations => {
        if ( status == 'pending_false' ) {
          ot.operations = aq.where(operations, op => !op.precondition_value);
        } else if ( status == 'pending_true' ) {
          ot.operations = aq.where(operations, op => op.precondition_value);
        } else {
          ot.operations = operations;
        }
        aq.each(ot.operations, op => { 
          aq.each(selected_ops, sop => {
            if ( op.id == sop.id ) {
              op.selected = true;
            }
          })
        })
        $scope.jobs = aq.uniq(aq.collect(ot.operations,op => op.job_id));
        $scope.$apply();
      })

    }

    $scope.choose = function(ot,status,val,job_id) {
      aq.each(ot.operations, op => {
        if ( op.operation_type_id == ot.id && op.status == status && ( !job_id || op.job_id == job_id )) {
          op.selected = val;
        }
      });
    }

    $scope.batch = function(ot) {

      var ops = aq.where(ot.operations, op => op.selected);

      if ( ops.length > 0 ) {
        ot.schedule(ops).then( () => {
          ot.numbers.pending_true -= ops.length;
          ot.numbers.scheduled += ops.length;        
          $scope.select(ot,'scheduled',ops);
          $scope.$apply();
        });
      }

    }

    $scope.unschedule = function(ot,jid) {

      var ops = aq.where(ot.operations,op => op.selected && op.job_id == jid);

      if ( ops.length > 0 ) {     
        ot.unschedule(ops).then( () => {
          ot.numbers.pending_true += ops.length;
          ot.numbers.scheduled -= ops.length;    
          $scope.select(ot,'pending_true',ops);    
          $scope.$apply();
        });
      } else {
        console.log("No operations selected")
      }

    }

  }]);

})();
