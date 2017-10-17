(function() {

  var w = angular.module('aquarium');

  w.controller('technicianCtrl', [ '$scope', '$http', '$attrs', '$cookies',
                        function (  $scope,   $http,   $attrs,   $cookies ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    let job_id = parseInt(aq.url_path()[2]);

    AQ.Job.find(job_id).then(job => {
      $scope.job = job;
      $scope.job.state = JSON.parse($scope.job.state);
      $scope.job.steps = aq.where($scope.job.state, s => s.operation == 'display')
    })

    $scope.state = {
      index: 0
    };

    $scope.keyDown = function(evt) {

      switch(evt.key) {

        case "ArrowLeft":
        case "ArrowUp":
          if ( $scope.state.index > 0 ) {
            $scope.state.index--;
          }
          break;
        case "ArrowRight":
        case "ArrowDown":
          if ( $scope.state.index < $scope.job.steps.length - 1 ) {
            $scope.state.index++;
          }
          break;

        default:

      }

    }

  }]);

})();
