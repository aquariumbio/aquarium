(function() {

  var w = angular.module('aquarium'); 

  w.controller('operationTypeTestAllCtrl', [ '$scope', '$http', '$mdDialog', '$window', 
                  function (  $scope,   $http,   $mdDialog,   $window ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }
    AQ.config.no_items_in_backtrace = true;
    $scope.tests = [];

    $scope.state = {
      active_category: null,
      done: 0,
      num_tests: 0,
      num_errors: 0
    }

    AQ.OperationType.where({deployed: true}).then(operation_types => {
      $scope.operation_types = operation_types;
      $scope.categories = aq.uniq(aq.collect(operation_types, ot => ot.category)).sort()
      $scope.$apply()
    });

    function perform(test) {

      test.status = "preparing";      

      return AQ
        .get(`/operation_types/${test.id}/random/3`)
        .then(response => {
          test.test_operations = response.data;
          test.status = "running";
          return test;
        })
        .then(test => 
          AQ.post("/operation_types/test", test).then(response => {
            test.status = "done";
            test.results = {
              operations: aq.collect(response.data.operations, op => AQ.Operation.record(op)),
              plans: aq.collect(response.data.plans, plan => AQ.Plan.record(plan)),
              job: AQ.Job.record(response.data.job)
            }
            $scope.state.done++;
            test.status = test.results.job.backtrace.last.type;
            if ( test.status != 'complete' ) {
              $scope.state.num_errors++;                
            }
          })
        )
        .catch(response => {
          if ( response.data.error ) {
            test.error = response.data.error;
          } else if ( response.data.errors ) {
            test.error = response.data.errors.join(", ")
          }
          test.status = "error";
          $scope.state.done++;
          $scope.state.num_errors++;
        });      

    }

    $scope.test_category = function(category) {

      $scope.state.active_category = category;
      $scope.tests = aq.where($scope.operation_types, ot => ot.category == category)
                       .sort((a,b) => a.name < b.name);
      $scope.state.num_tests = $scope.tests.length;
      $scope.state.done = 0;
      $scope.state.num_errors = 0;

      aq.each($scope.tests,test => perform(test));

    }

    $scope.status_class = function(status) {
      let s = "pull-right status";
      if ( status == 'aborted' || status == 'error' ) {
        s += " status-error";
      } else if ( status == 'complete' ) {
        s += ' status-complete';
      }
      return s;
    }

  }]);

})()