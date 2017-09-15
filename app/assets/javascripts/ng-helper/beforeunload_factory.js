(function() {
    "use strict";
    let w = angular.module('aquarium');

    // Factory to broadcast `onbeforeunload` event to angular
    // see https://gist.github.com/981746/3b6050052ffafef0b4df
    //
    w.factory('beforeUnload', function ($rootScope, $window) {
        // Events are broadcast outside the Scope Lifecycle


        // Listener should signal need for default dialog box by calling e.preventDefault()
        $window.onbeforeunload = function (e) {
            let event = $rootScope.$broadcast('onBeforeUnload');
            if (event.defaultPrevented) {
                return true;
            }
        };

        $window.onunload = function () {
            $rootScope.$broadcast('onUnload');
        };
        return {};
    })
        .run(function (beforeUnload) {
            // Must invoke the service at least once
        });
})();