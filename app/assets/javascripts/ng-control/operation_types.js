(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('operationTypesCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                        function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.operation_types = [];
    $scope.current_ot = { name: "Loading" }
    $scope.user = new User($http);  
    $scope.mode = 'definition';

    $http.get('/operation_types.json').then(function(response) {
      $scope.operation_types = response.data;
      $scope.current_ot = $scope.operation_types[0];      
    });

    $http.get('/object_types.json').then(function(response) {
      $scope.object_types = response.data;
    });

    $http.get('/sample_types.json').then(function(response) {
      $scope.sample_types = response.data;
    });

    $scope.tab = function(mode) {
      return mode == $scope.mode ? "active" : "";
    }

    $scope.set_mode = function(mode) {
      $scope.mode = mode;
    }

    $scope.choose = function(ot) {
      $scope.current_ot = ot;
    }

    $scope.ot_class = function(ot) {
      if ( $scope.current_ot == ot ) {
        return "op-type op-type-current";
      }  else {
        return "op-type";
      }
    }

    $scope.capitalize = function(string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    }

    // Save

    $scope.save_ot = function(ot) {
      if ( confirm ( "Are you sure you want to save this operation type definition?" ) ) {
        if ( ot.id ) {
          $http.put("/operation_types/" + ot.id,ot).then(function(response) {
            var i = $scope.operation_types.indexOf(ot);
            $scope.operation_types[i] = response.data;
          });          
        } else {
          $http.post("/operation_types",ot).then(function(response) {
            var i = $scope.operation_types.indexOf(ot);
            $scope.operation_types[i] = response.data;            
          });
        }
      }
    }

    // Edit operation types

    $scope.new_operation_type = function() {
      var new_ot = {
        name: "New Operation Type",
        field_types:[]
      };
      $scope.operation_types.push(new_ot);
      $scope.current_ot = new_ot;
    }

    $scope.add_io = function(role) {
      $scope.current_ot.field_types.push({
        role: role,
        name: "New " + role,
        allowable_field_types: []
      })
    }

    $scope.add_aft = function(io) {
      io.allowable_field_types.push({
        sample_type: { name: "" },
        object_type: { name: "" }
      });
    }

    $scope.remove_io = function(io) {
      aq.remove($scope.current_ot.field_types,io);
    }

    $scope.remove_aft = function(io,aft) {
      aq.remove(io.allowable_field_types,aft);
    }


  }]);

})();
