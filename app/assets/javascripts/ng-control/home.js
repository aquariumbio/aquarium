(function() {

  var w = angular.module('aquarium');

  w.controller('homeCtrl', [ '$scope', '$http', '$attrs', '$cookies',
                  function (  $scope,   $http,   $attrs,   $cookies ) {


    $scope.is_chrome = !!window.chrome && !!window.chrome.webstore;

  }]);

})();
