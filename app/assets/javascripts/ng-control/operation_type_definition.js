(function() {

  var w = angular.module('aquarium'); 
  
  w.controller('operationTypeDefinitionCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                                     function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.add_io = function(role) {
      $scope.current_operation_type.field_types.push(
        AQ.FieldType.record({
          role: role,
          ftype: 'sample',
          name: "New " + role,
          allowable_field_types: []
        })
      )
    };

    $scope.add_parameter = function(role) {
      $scope.current_operation_type.field_types.push({
        role: role,
        ftype: 'number',
        name: "New " + role,
        allowable_field_types: []
      })
    };

    $scope.add_aft = function(io) {
      io.allowable_field_types.push({
        sample_type: { name: "" },
        object_type: { name: "" }
      });
    };

    $scope.remove_io = function(io) {
      aq.remove($scope.current_operation_type.field_types,io);
    };

    $scope.remove_aft = function(io,aft) {
      aq.remove(io.allowable_field_types,aft);
    }

  }]);

})();
