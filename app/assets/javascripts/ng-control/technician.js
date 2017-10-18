(function() {

  var w = angular.module('aquarium');

  w.controller('technicianCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce',
                        function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    let job_id = parseInt(aq.url_path()[2]);

    AQ.Job.find(job_id).then(job => {
      $scope.job = job;
      // these should be moved to the model   V
      $scope.job.state = JSON.parse($scope.job.state);
      $scope.job.steps = aq.where($scope.job.state, s => s.operation == 'display');
    })

    $scope.state = {
      index: 0
    };

    $scope.content_type = function(line) {
      var type = Object.keys(line)[0];
      return type;
    };

    $scope.content_value = function(line) {
      var k = Object.keys(line)[0];
      if ( typeof line[k] === "string" ) {
        return $sce.trustAsHtml(line[k]);
      } else {
        return line[k];
      }
    };

    $scope.table_class = function(cell) {
      var c = "";
      if ( cell == null ) {
        c += " td-null-cell";
      } else if ( cell.class ) {
        c += cell.class;
      }
      if ( cell && cell.check ) {
        c += " td-check"
      }
      if ( cell && cell.type ) {
        c += " td-input"
      }
      return c;
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
