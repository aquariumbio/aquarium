(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', []); 
  } 

  w.controller('inventoryCtrl', [ '$scope', '$http', '$attrs', function ($scope,$http,$attrs) {

    $scope.num_items = function(sample,container) {
      var items = aq.where(sample.items,function(i) {
        return i.object_type_id == container.id;
      });
      return items.length;
    }

  }])

})();