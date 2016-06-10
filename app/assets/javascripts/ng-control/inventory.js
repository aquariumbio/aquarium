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

    $scope.delete = function(item) {
      if ( confirm("Are you sure you want to mark this item as deleted?") ) {
        $http.get("/browser/delete_item/" + item.id).then(function(response) {
          item.location = response.data.location;
        });
      }
    }

    $scope.restore = function(item) {
      $http.get("/browser/restore_item/" + item.id).then(function(response) {
        item.location = response.data.location;
        if ( response.data.errors ) {
          aq.each(response.data.errors,function(e) {
            console.log(e);
          })
        }
      });
    }

    $scope.notes = function(item) {
      var das = aq.where(item.data_associations,function(da) { return da.key == "notes"; });      
      if ( das.length > 0 ) {
        return new DataAssociation($http).from(das[0]).value();
      } else {
        return null;
      }
    }

    $scope.edit_note = function(item) {
      item.note = $scope.notes(item);
      item.edit_modal = true;
    }

  }]);

})();
