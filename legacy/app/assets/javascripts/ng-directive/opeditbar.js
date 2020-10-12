(function() {

  var w = angular.module('aquarium'); 

  w.directive('opeditbar', [

    function() {

      return {

        restrict: 'C',

        link: function(scope, element) {

          var innerElement = element.find('inner');

          scope.$watch(
            function() {
              return innerElement[0].offsetHeight;
            },
            function(value, oldValue) {
              setTimeout(function() {
                element.css('height', innerElement[0].offsetHeight+'px');
                scope.status = innerElement[0].offsetHeight;
              }, 30);
            }, true);

        }

      };

    }

  ]);

})();  