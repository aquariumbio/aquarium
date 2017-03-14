(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.directive("da", function() {

    return {

      restrict: 'AE',

      scope: { record: '=' },

      link: function($scope,$element,$attributes) {

        $scope.new = function() {

        }

        $scope.save = function(da) {

          var temp = {},
              old_object = da.object;
          temp[da.key] = da.new_value;
          da.object = JSON.stringify(temp);

          da.save()
            .then(() => { da.value = da.new_value, AQ.update() })
            .catch(() => { da.object = old_object; })

        }

      },

      replace: true,

      template: $('#data_associations_template').html()

    }

  });
  
})();



