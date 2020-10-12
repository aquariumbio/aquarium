(function() {

  var w = angular.module('aquarium'); 

  w.controller('buildPlanCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                       function (  $scope,   $http,   $attrs,   $cookies ) {
    
    $scope.more = function(ot) {
      ot.operations.push(empty_goal(ot));
    };

    $scope.drop = function(ot,op) {
      var index = ot.operations.indexOf(op);
      if (index > -1) {
        ot.operations.splice(index, 1);
      }      
    };

    $scope.add_to_array = function(fvs,name) {
      if ( typeof fvs[name].sample == "string" ) {
        fvs[name].sample = [];
      }
      fvs[name].sample.push("");
    };

    $scope.delete_from_fvs = function(fv,i) {
      fv.splice(i, 1);
    };

    $scope.incomplete_field_types = function(goal, role) {
      // Only return field_types that have afts with sample types
      return aq.where(goal.field_types, function(ft) { 
        if ( ft.role != role ) {
          return false;
        } else {
          var afts = aq.where(ft.allowable_field_types,function(aft) {
            return aft.sample_type; 
          });
          return afts.length != 0;
        }
      });
    }

  }]);

})();