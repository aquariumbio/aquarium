(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.controller('inventoryCtrl', [ '$scope', '$http', '$attrs', 
                       function (  $scope,   $http,   $attrs ) {

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
        item.new_location = response.data.location;
        if ( response.data.errors ) {
          aq.each(response.data.errors,function(e) {
            console.log(e);
          })
        }
      });
    }

  }]);

})();
