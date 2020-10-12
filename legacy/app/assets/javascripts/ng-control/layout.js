(function() {

    let w = angular.module('aquarium');

    w.controller('layoutCtrl', [ '$scope', '$http', '$attrs', '$cookies',
                      function (  $scope,   $http,   $attrs,   $cookies ) {

    /*
     * The default listener for `onBeforeUnload` event broadcast by the handler for browser
     * `onbeforeunload`.
     * The default behavior is to do nothing.
     *
     * See factory definition in ng-helper/beforeunload_factory.js.
     */
    $scope.$on('onBeforeUnload', function (e) { });

    $scope.range = function(x) {
      return aq.range(x);
    };

    $scope.openMenu = function($mdMenu, ev) {
      originatorEv = ev;
      $mdMenu.open(ev);
    };

  }]);

})();                    
