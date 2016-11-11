(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.directive("samplecomplete", function() {

    samples_for = function(names,types) {
      var samples = [];
      if ( types == "all" ) {
        for ( var type in names ) {
          samples = samples.concat(names[type]);
        }
      } else {
        aq.each(types,function(type) {
          samples = samples.concat(names[type])
        });
      }
      return samples;    
    }

    return {
      restrict: 'A',
      scope: { samplecomplete: '=', ngModel: '='  },
      link: function($scope,$element,$attributes) {

        var sample_names = $scope.$parent.sample_names;

        var types = $scope.samplecomplete;
        $element.autocomplete({
          source: samples_for($scope.$parent.sample_names,types),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });

        function changed() {
          return sample_names != $scope.$parent.sample_names;
        }

        $scope.$watch(changed, function (v) {
          console.log("Updating samplecomplete")
          types = $scope.samplecomplete;
          sample_names = $scope.$parent.sample_names;
          $element.autocomplete({
            source: samples_for($scope.$parent.sample_names,types),
            select: function(ev,ui) {
              $scope.ngModel = ui.item.value;
              $scope.$apply();
            }
          });
        });

      }
    }

  });

  w.directive("projectcomplete", function() {

    return {
      restrict: 'A',
      scope: { ngModel: '=' },
      link: function($scope,$element,$attributes) {
        $element.autocomplete({
          source: aq.collect($scope.$parent.projects,function(p) { return p.name; }),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });
      }
    }

  });  

})();