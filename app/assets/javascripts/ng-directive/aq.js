(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.directive("ftautocomplete", function() {

    return {
      restrict: 'A',
      scope: { ftautocomplete: '=', ngModel: '=' },
      link: function($scope,$element,$attributes) {

        var ft = $scope.ftautocomplete;

        $element.autocomplete({
          source: AQ.sample_names_for([ft.chosen_sample_type_name()]),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });
        
        $scope.$watch('ftautocomplete.aft_choice', function (v) {
          $element.autocomplete({
            source: AQ.sample_names_for([ft.chosen_sample_type_name()]),
            select: function(ev,ui) {
              $scope.ngModel = ui.item.value;
              $scope.$apply();
            }
          });
          $element.val("");
        });

      }
    }

  });
  
})();
