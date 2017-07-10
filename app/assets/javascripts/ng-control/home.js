(function() {

  var w;
 
  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('homeCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                  function (  $scope,   $http,   $attrs,   $cookies ) {


    $scope.is_chrome = !!window.chrome && !!window.chrome.webstore;

  }]);

})();                    
