(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('buildPlanCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                       function (  $scope,   $http,   $attrs,   $cookies ) {
    
    $scope.more = function(ot) {
      ot.operations.push({ fvs: {} })
    }

    $scope.drop = function(ot,op) {
      var index = ot.operations.indexOf(op);
      if (index > -1) {
        ot.operations.splice(index, 1);
      }      
    }

    $scope.add_to_array = function(fvs,name) {
      if ( ! fvs[name] ) {
        fvs[name] = [];
      }
      fvs[name].push("");
    }

    $scope.delete_from_fvs = function(fv,i) {
      fv.splice(i, 1);
    }

  }]);

})();