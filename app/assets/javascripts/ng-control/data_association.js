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

    $scope.notes = function(parent) {
      var das = aq.where(parent.data_associations,function(da) { return da.key == "notes"; });      
      if ( das.length > 0 ) {
        return das[0].value();
      } else {
        return null;
      }
    }

    $scope.edit_note = function(parent) {
      parent.note = $scope.notes(parent);
      parent.edit_modal = true;
    }    

    function set_da(parent,key,value) {
      var das = aq.where(parent.data_associations,function(da) { return da.key == key; });
      if ( das.length > 0 ) {
        das[0].set(value);
      } else {
        var obj = {};
        obj[key] = value;
        var da = new DataAssociation($http).from({
          key: key,
          object: JSON.stringify(obj),
          id: parent.id
        });
        console.log(da);
        if ( ! parent.data_associations ) {
          parent.data_associations = [];
        }
        parent.data_associations.push(da);
        console.log(parent.data_associations);
      }
    }

    $scope.save_note = function(parent,parent_class) {

      $http.post(
        "/browser/save_data_association",
        {
          key: "notes",
          value: parent.note,
          parent_class: parent_class,
          id: parent.id
        }
      ).then(function(result) {
        console.log(result.data);
        parent.edit_modal = false;
        set_da(parent,"notes",parent.note);
      })

    }

  }]);

})();