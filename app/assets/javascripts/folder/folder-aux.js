(function() {

  var w;
  try {
    w = angular.module('folders'); 
  } catch (e) {
    w = angular.module('folders', []); 
  } 

  w.factory('focus', function($timeout, $window) {
    return function(id) {
      $timeout(function() {
        var element = $window.document.getElementById(id);
        if(element)
          element.focus();
      });
    };
  });

  w.directive('eventFocus', function(focus) {
    return function(scope, elem, attr) {
      elem.on(attr.eventFocus, function() {
        focus(attr.eventFocusId);        
      });
      scope.$on('$destroy', function() {
        elem.off(attr.eventFocus);
      });
    };
  });

  w.directive('resize', function ($window) {
    return function (scope, element) {
        var w = angular.element($window);
        scope.getWindowDimensions = function () {
            return {
                'h': w.height()
            };
        };
        scope.$watch(scope.getWindowDimensions, function (newValue, oldValue) {
            scope.windowHeight = newValue.h;
            scope.windowWidth = newValue.w;

            scope.style = function () {
                return {
                    'height': (newValue.h - 160) + 'px'
                };
            };

        }, true);

        w.bind('resize', function () {
            scope.$apply();
        });
    }});

})();

