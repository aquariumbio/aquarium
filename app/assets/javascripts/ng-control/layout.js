(function() {

  var w = angular.module('aquarium'); 

  w.controller('layoutCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                      function (  $scope,   $http,   $attrs,   $cookies ) {

    $scope.range = function(x) {
      return aq.range(x);
    }

    $scope.openMenu = function($mdMenu, ev) {
      originatorEv = ev;
      $mdMenu.open(ev);
    };

  }]);

})();                    
