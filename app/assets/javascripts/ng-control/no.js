(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('noCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                function (  $scope,   $http,   $attrs,   $cookies ) {

    // For use on pages that need an angular controller to function, but that
    // otherwise don't have any logic. Helps make the aq2.html.erb layout look
    // better.

  }]);

})();                    
