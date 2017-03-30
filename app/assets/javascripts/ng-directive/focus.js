
(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

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
