(function() {

  var w = angular.module('aquarium'); 

  w.directive("da", function() {

    return {

      restrict: 'AE',

      scope: { record: '=', noedit: '=', keywidth: '=?' },

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



