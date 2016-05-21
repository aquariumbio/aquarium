(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('sampleTypeEditCtrl', [ '$scope', '$http', '$attrs', function ($scope,$http,$attrs,treeAjax) {

    $scope.sample_type = {};
    $scope.sample_types = {};
    $scope.messages = [];

    $scope.$watch('stid', function () {
      if ( $scope.stid > 0 ) {
        $scope.mode = 'edit';
        $http.get('/sample_types/' + $scope.stid + '.json').
          then(function(response) {
            $scope.sample_type = response.data;
          });
      } else {
        $scope.mode = 'new';
        $scope.sample_type = {
          name: "New sample type",
          description: "New sample type description",
          field_types: []
        }
      }
    });

    $http.get('/sample_types.json').
      then(function(response) {
        $scope.sample_types = response.data;
      });

    $scope.add_field = function() {
      $scope.sample_type.field_types.push({
        name: "New Field",
        ftype: "string",
        required: false,
        array: false,
        choices: [],
        allowable_field_types: []
      })
    }

    $scope.add_option = function(ft) {
      ft.allowable_field_types.push({
        field_type_id: ft.id,
        sample_type_id: 1
      })
    }

    $scope.remove_field = function(ft) {
      ft.deleted = true;
    }

    $scope.remove_aft = function(aft) {
      aft.deleted = true;
    }

    $scope.save = function() {

      if ( $scope.mode == 'new' ) {

        $http.post('/sample_types.json', { sample_type: $scope.sample_type } ).
          then(function(response) {
            var st = response.data.sample_type;
            $scope.messages.push("Created new sample with id " + st.id + ".")
            $scope.stid = st.id;
            $scope.mode = 'edit';
          });

        } else {

        $http.put('/sample_types/' + $scope.stid + '.json', { sample_type: $scope.sample_type } )
          .then(function(response) {
            $scope.messages.push("Saved sample type " + $scope.stid + ".")
          });

      }

    }

    $scope.clear_messages = function() {
      $scope.messages = [];
    }

  }]);

})();