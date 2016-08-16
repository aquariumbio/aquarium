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

    $scope.save_ot = function(ot) {
      if ( confirm ( "Are you sure you want to save this operation type definition?" ) ) {
        if ( ot.id ) {
          $http.put("/operation_types/" + ot.id,ot).then(function(response) {
            var i = $scope.operation_types.indexOf(ot);
            $scope.operation_types[i] = response.data;
            $scope.current_ot = response.data;
          });          
        } else {
          $http.post("/operation_types",ot).then(function(response) {
            var i = $scope.operation_types.indexOf(ot);
            $scope.operation_types[i] = response.data;            
            $scope.current_ot = response.data;            
          });
        }
      }
    }

    $scope.new_operation_type = function() {
      var new_ot = {
        name: "New Operation Type",
        field_types:[],
        protocol: { name: 'protocol', content: 'class Protocol\n  def main\n    {}\n  end\nend'},
        cost_model: { name: 'cost_model', content: 'def cost(op)\n  { labor: 0, materials: 0 }\nend' },
        documentation: { name: 'documentation', content: "New Operation Type\n===\n\nDocumentation here"}
      };
      $scope.operation_types.push(new_ot);
      $scope.current_ot = new_ot;
    }

  }]);

})();
