(function() {

  var w = angular.module('aquarium'); 

  w.controller('operationTypeTestCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                               function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    $scope.randomize = function(operation_type) {

      if ( !operation_type.batch_size ) {
        operation_type.batch_size = 1;
      }

      operation_type.test_operations = null;
      operation_type.randomizing = true;

      $http.get("/operation_types/" + operation_type.id + "/random/" + operation_type.batch_size).then(function(response) {
        operation_type.randomizing = false;
        if ( response.data.error ) {
          operation_type.test_error = response.data.error;
          if ( response.data.backtrace ) {
            operation_type.test_error += response.data.backtrace[0]
          }
        } else {
          operation_type.test_operations = response.data;
        }
      });

    };

    $scope.save_and_test = function(operation_type) {

      if ( !operation_type.protocol.no_edit ) {

        $http.post("/operation_types/code", {
          id: operation_type.id,
          name: "protocol",
          content: operation_type.protocol.content
        }).then(function(response) {
          
          operation_type.recompute_getter("protocol");

          if ( !operation_type.precondition.no_edit ) {
            $http.post("/operation_types/code", {
              id: operation_type.id,
              name: "precondition",
              content: operation_type.precondition.content
            }).then(function(response) {
              operation_type.precondition.changed = false;
              $scope.test(operation_type);
            });
          }

        });

      }

    };

    $scope.test = function(operation_type) {
      if ( operation_type.test_operations && operation_type.test_operations.length > 0 ) {
        operation_type.test_results = null;
        operation_type.test_error = null;
        operation_type.running_test = true;
        $http.post("/operation_types/test", operation_type.remove_predecessors()).then(function(response) {
          operation_type.running_test = false;
          aq.each(operation_type.field_types, ft => ft.recompute_getter('predecessors'));
          if ( response.data.error ) {
            operation_type.test_error = response.data.error.replace(/\(eval\):/g, "Line ");
            console.log(operation_type.test_error);
          } else {
            operation_type.test_results = response.data;
            operation_type.test_results.job.backtrace = JSON.parse(operation_type.test_results.job.state);
          }
        });
      }
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
        c += " krill-td-null-cell";
      } else if ( cell.class ) {
        c += cell.class;
      }
      if ( cell && cell.check ) {
        c += " krill-td-check"
      }
      if ( cell && cell.type ) {
        c += " krill-td-input"
      }      
      return c;
    };

    $scope.backtrace = function(step) {

      var relevant_messages = step.backtrace;
      return aq.collect(relevant_messages, function(msg) { return msg.replace(/\(eval\):/g, "Line ") });

    };

    $scope.is_part = function(ot,fv) {

      var fts = aq.where(ot.field_types, function(ft) {
        return ft.role == fv.role && ft.name == fv.name;
      });

      if ( fts.length > 0 ) {
        return fts[0].part;
      } else {  
        return false;
      }

    }

  }]);

})();
