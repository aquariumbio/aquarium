(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('operationTypeTestCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                               function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.randomize = function(ot) {

      if ( !ot.batch_size ) {
        ot.batch_size = 1;
      }

      ot.test_operations = null;
      ot.randomizing = true;

      $http.get("/operation_types/" + ot.id + "/random/" + ot.batch_size).then(function(response) {
        ot.randomizing = false;        
        if ( response.data.error ) {
          ot.test_error = response.data.error
          if ( response.data.backtrace ) {
            ot.test_error += response.data.backtrace[0]
          }
        } else {
          ot.test_operations = response.data;
        }
      });

    }

    $scope.save_and_test = function(ot) {

      $http.post("/operation_types/code", {
        id: ot.id,
        name: "protocol",
        content: ot.protocol.content
      }).then(function(response) {
        
        $http.post("/operation_types/code", {
          id: ot.id,
          name: "precondition",
          content: ot.precondition.content
        }).then(function(response) {
          ot.precondition.changed = false;
          $scope.test(ot);
        });

      });

    }

    $scope.test = function(ot) {
      ot.test_results = null;
      ot.test_error = null;
      ot.running_test = true;
      $http.post("/operation_types/test", ot.remove_predecessors()).then(function(response) {
        ot.running_test = false;
        aq.each(ot.field_types, ft => ft.recompute_getter('predecessors'));        
        if ( response.data.error ) {
          ot.test_error = response.data.error.replace(/\(eval\):/g, "Line ");
          console.log(test_error);
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
      if ( cell && cell.type ) {
        c += " krill-td-input"
      }      
      return c;
    }

    $scope.backtrace = function(step) {

      var relevant_messages = step.backtrace;
      return aq.collect(relevant_messages, function(msg) { return msg.replace(/\(eval\):/g, "Line ") });

    }

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
