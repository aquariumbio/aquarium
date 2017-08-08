
(function() {

  var w = angular.module('aquarium'); 

  w.directive("autofocus", function() {

     return {

       restrict: 'A',

       scope : { autofocus: '=' },

       link : function(scope, element) {
         scope.$watch('autofocus', function(value) {
           if (value) {
             element[0].focus();
           }
         });
       }

    };

  });

})();
