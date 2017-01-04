(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.directive("opener", function() {

    return {

      restrict: 'A',

      scope: { opener: '=' },

      link: function($scope,$element,$attributes) {

        $scope.toggle = function() {
          $scope.opener = !$scope.opener;
        }

      },

      template: "<span class='clickable' ng-if='opener' ng-click='toggle()'>&#9660;</span>" + 
                "<span class='clickable' ng-if='!opener' ng-click='toggle()'>&#9658;</span>"

    }

  });
  
})();
