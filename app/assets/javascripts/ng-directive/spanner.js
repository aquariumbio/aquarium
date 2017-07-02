(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.directive("spanner", function() {

    return {

      restrict: 'EA',
      transclude: true,
      scope: { w: '=', p: '=', c: '@c' },
      replace: true,
      template: "<span class='spanner-cell {{c}}' " + 
                "      style='width: calc({{w}}% - {{p ? p : 0}}px);' " +
                "      ng-transclude></span>"

    }

  });
  
})();
