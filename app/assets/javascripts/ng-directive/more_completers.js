(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  // w.directive("sampletypecomplete", function() {

  //   return {
  //     restrict: 'A',
  //     scope: { ngModel: '=' },
  //     link: function($scope,$element,$attributes) {
  //       $element.autocomplete({
  //         source: aq.collect($scope.$parent.sample_type_names,function(p) { return p; }),
  //         select: function(ev,ui) {
  //           $scope.ngModel = ui.item.value;
  //           $scope.$apply();
  //         }
  //       });
  //     }
  //   }

  // });  

  w.directive("usercomplete", function() {

    return {
      restrict: 'A',
      scope: { ngModel: '=' },
      link: function($scope,$element,$attributes) {
        $($element).autocomplete({
          source: aq.collect($scope.$parent.user.all,function(p) { return p.login; }),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });
      }
    }

  });    

})();