(function() {

  var w;
  try {
    w = angular.module('folders'); 
  } catch (e) {
    w = angular.module('folders', ['puElasticInput']); 
  } 

  w.directive('autocomplete', function(focus) {

    return {

      restrict: 'A',

      scope: { part: "=" },

      link: function($scope,$element) {

        if ( $scope.part.alternatives.length > 0 && $scope.part.alternatives[0].sample_type ) {

          var stid = parseInt($scope.part.alternatives[0].sample_type.split(':')[0]);

          $.ajax({
            url: '/sample_list?id=' + stid
          }).done(function(samples) {
            $element.autocomplete({
              source: samples
            });
          });

        }

      }

    }

  });

})();