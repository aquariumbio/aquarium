(function() {
    "use strict";
    let w = angular.module('aquarium');

    // Factory to broadcast `onbeforeunload` event to angular
    // see https://gist.github.com/981746/3b6050052ffafef0b4df
    //
   w.run(['$rootScope', '$window', ($rootScope, $window) => {
    $window.onbeforeunload = function (e) {
      let event = $rootScope.$broadcast('onBeforeUnload');
      if (event.defaultPrevented) {
        return true;
      }
     }
   }]);

})();