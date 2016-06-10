(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('daCtrl', [ '$scope', '$http', '$attrs', function ($scope,$http,$attrs) {

    $scope.toggle_modal = function(da) {
      da.modal = !da.modal;
    };    

    $scope.is_image = function(da) {
      return da.upload.upload_content_type.split("/")[0] == "image";
    }

    $scope.title = function(da) {
      return "Data associated with " + da.parent_class + " " + da.id + ". Key: " + da.key;
    }

  }]);

})();