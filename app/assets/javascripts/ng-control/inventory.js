(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('inventoryCtrl', [ '$scope', '$http', '$attrs', 
                       function (  $scope,   $http,   $attrs ) {

    $scope.num_items = function(sample,container) {
      var items = aq.where(sample.items,function(i) {
        return ( sample.show_deleted || i.location != 'deleted' ) && i.object_type_id == container.id;
      });
      return items.length;
    }

    $scope.num_collections = function(sample,container) {
      var collections = aq.where(sample.collections,function(c) {
        return ( sample.show_deleted || c.location != 'deleted' ) && c.object_type_id == container.id;
      });
      return collections.length;
    }

    $scope.visible_inventory = function(sample) {
      var s = aq.sum(sample.containers,function(con) {
        return $scope.num_items(sample,con) + $scope.num_collections(sample,con);
      });
      return s;
    }

    $scope.empty = function(data) {
      return !data || $.isEmptyObject(data);
    }

    $scope.item_filter = function(sample,container) {
      return function(item) {
        return item.object_type_id == container.id 
          && ( sample.show_deleted || item.location != 'deleted' );
      }
    }

    $scope.collection_filter = function(sample) {
      return function(item) {
        return sample.show_deleted || item.location != 'deleted';
      }
    }    

  }])

})();
