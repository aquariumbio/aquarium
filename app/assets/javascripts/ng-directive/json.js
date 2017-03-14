(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.directive('jsonText', function() {
    return {
      restrict: 'A',
      require: 'ngModel',
      link: function(scope, element, attr, ngModel) {            
        function into(input) {
          try {
            return JSON.parse(input);
          } catch(e) {
            return {};
          }
        }
        function out(data) {
          return JSON.stringify(data,null,2);
        }
        ngModel.$parsers.push(into);
        ngModel.$formatters.push(out);
      }
    };
  });    

})();