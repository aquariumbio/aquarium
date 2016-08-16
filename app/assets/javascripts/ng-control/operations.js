
(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('operationsCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                        function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.operation_types = [];
    $scope.operations = [];
    $scope.current_ot = { name: "Loading" }

    $scope.user = new User($http);  

    $http.get('/operation_types.json').then(function(response) {
      $scope.operation_types = response.data;
      $scope.current_ot = $scope.operation_types[0];
    }); 

    $http.get('/operations.json').then(function(response) {
      $scope.operations = response.data;
      $http.get('/operations/jobs.json').then(function(response) {
        $scope.jobs = response.data;
      });      
    });

    $scope.operation_type = function(operation) {
      var m = aq.where($scope.operation_types,function(ot) {
        return ot.id == operation.operation_type_id;
      });
      return m[0];
    }  

    $scope.choose = function(ot) {
      $scope.current_ot = ot;
    }

    $scope.number = function(ot,status) {
      var ops = aq.where($scope.operations, function(o) { return o.status == status && o.operation_type_id == ot.id });
      return ops.length;
    }

    $scope.number_class = function(ot,status) {
      var c = "";
      if ( $scope.number(ot,status) == 0 ) {
        c += "number-none";
      } else {
        c += "number-some";
      }
      return c;
    }

    $scope.op_type_class = function(ot) {
      var c = "op-type";
      if ( ot == $scope.current_ot ) {
        c += " op-type-selected";
      }
      return c;
    }

    $scope.select = function(ot,val) {
      aq.each($scope.operations, function(op) {
        if ( op.operation_type_id == ot.id && op.status == "pending" ) {
          op.selected = val;
        }
      });
    }

    $scope.batch = function(ot) {

      var ops = aq.where($scope.operations, function(op) {
        return op.operation_type_id == ot.id && op.selected;
      });

      var op_ids = aq.collect(ops,function(op) { 
        op.selected = false;
        return op.id; 
      });

      $http.post("/operations/batch", { operation_ids: op_ids }).then(function(response) {
        $scope.jobs = response.data.jobs;
        aq.each(ops,function(op) {
          aq.each(response.data.operations,function(updated_op) {
            if ( op.id == updated_op.id ) {
              op.job_id = updated_op.job_id;
              op.status = "scheduled";
            }
          });
        });
      });

    }

    $scope.jobs_for_current_ot = function(job) {

      var ops = aq.where($scope.operations,function(op) {
        return op.job_id == job.id;
      });

      if ( ops.length > 0 ) {
        return ops[0].operation_type_id == $scope.current_ot.id;
      } else {
        return false;
      }  

    }

  }]);

})();
