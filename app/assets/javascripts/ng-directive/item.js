(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.directive("item", function() {

    return {

      restrict: 'AE',

      scope: { item: '=', container: "=", sample: "=", nolink: "=" },

      link: function($scope,$element,$attributes) {

        $scope.toggle = function() {
          if ( !$scope.disabled ) {
            $scope.model = !$scope.model;
          }
        }

      },

      replace: true,

      template: $('#item_template').html()

    }

  });
  
})();


