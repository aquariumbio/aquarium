(function() {

  var w = angular.module('aquarium'); 

  w.directive('blink', ['$interval', function($interval) {
    return function(scope, element, attrs) {
        var timeoutId;
        
        var blink = function() {
          if ( element.hasClass('highlight-running-low') ) {
            element.removeClass('highlight-running-low');
          } else {
            element.addClass('highlight-running-low')
          }
        }
        
        timeoutId = $interval(function() {
          blink();
        }, 800);
      
        element.css({
          'display': 'inline-block'
        });
        
        element.on('$destroy', function() {
          $interval.cancel(timeoutId);
        });
      };
  }]);

})();