(function() {

  var w = angular.module('aquarium'); 

  w.directive("item", function() {

    return {

      restrict: 'AE',

      scope: { item: '=', container: "=", sample: "=", nolink: "=" },

      link: function($scope,$element,$attributes) {

        $scope.toggle = function() {
          if ( !$scope.disabled ) {
            $scope.modal = !$scope.modal;
          }
        }

      },

      replace: true,

      template: $('#item_template').html()

    }

  });
  
})();


