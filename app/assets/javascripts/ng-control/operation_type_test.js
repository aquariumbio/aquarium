(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('operationTypeTestCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                               function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.randomize = function(ot) {

      if ( !ot.batch_size ) {
        ot.batch_size = 1;
      }

      ot.test_operations = null;

      $http.get("/operation_types/" + ot.id + "/random/" + ot.batch_size).then(function(response) {
        ot.test_operations = response.data;
      });

    }

    $scope.save_and_test = function(ot) {

      $http.post("/operation_types/code", {
        id: ot.id,
        name: "protocol",
        content: ot.protocol.content
      }).then(function(response) {
        ot.protocol.changed = false;
        $scope.test(ot);
      });

    }

    $scope.test = function(ot) {
      ot.test_results = null;
      ot.test_error = null;
      $http.post("/operation_types/test", ot).then(function(response) {
        if ( response.data.error ) {
          ot.test_error = response.data.error.replace(/\(eval\):/g, "Line ");
        } else {
          ot.test_results = response.data;
          ot.test_results.job.backtrace = JSON.parse(ot.test_results.job.state);
        }
      });
    }

    $scope.content_type = function(line) {
      var type = Object.keys(line)[0];
      if ( type == "item") { console.log(type); }
      return type;
    }

    $scope.content_value = function(line) {
      var k = Object.keys(line)[0];
      return line[k];
    }  

    $scope.table_class = function(cell) {
      var c = "";
      if ( cell == null ) {
        c += " krill-td-null-cell";
      } else if ( cell.class ) {
        c += cell.class;
      }
      if ( cell && cell.check ) {
        c += " krill-td-check"
      }
      return c;
    }

    $scope.backtrace = function(step) {

      var relevant_messages = step.backtrace;
      return aq.collect(relevant_messages, function(msg) { return msg.replace(/\(eval\):/g, "Line ") });

    }

  }]);

})();
