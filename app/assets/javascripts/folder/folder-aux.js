(function() {

  var w;
  try {
    w = angular.module('folders'); 
  } catch (e) {
    w = angular.module('folders', ['puElasticInput', 'cfp.hotkeys']); 
  } 

  w.factory('focus', [ '$timeout', '$window', function($timeout, $window) {
    return function(id) {
      $timeout(function() {
        var element = $window.document.getElementById(id);
        if(element)
          element.focus();
      });
    };
  }]);

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

  w.directive('space', [ '$window', function($window) {
    return {
      restrict: 'A',
      scope: { space: "=" },
      template: '<span style="width: {{10*space}}" class="spacer"></span>'
    }
  }]);

  w.directive('resize', [ '$window', function ($window) {
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
    }}]);

})();

