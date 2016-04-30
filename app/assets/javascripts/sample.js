(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', []); 
  } 

  w.controller('sampleEditCtrl', [ '$scope', '$http', '$attrs', function ($scope,$http,$attrs,treeAjax) {

    $scope.info = {};
    $scope.sample = {};
    $scope.sample_type = {};

    $.ajax({
      url: '/tree/all'
    }).done(function(sample_names) {
      $scope.sample_names = sample_names;
      $scope.samples_loaded = true;
    });    

    function setup() {
      aq.each($scope.sample.field_values,function(fv) {
        aq.fields[fv.name] = {
          value: fv.value,
          sample_type_id: fv.sample_type_id,
          item_type_id: fv.item_type_id
        }
      });
    }

    $scope.types = function(ft) {
      aq.collect(ft.allowable_field_types,function(aft) {
        aft.sample_type.name
      })
    }

    $scope.$watch('info', function () {

      if ( $scope.info.sid > 0 ) {
        $scope.mode = 'edit';
        $http.get('/samples/' + $scope.info.sid + '.json')
          .then(function(response) {
            $scope.sample = response.data;
          });

      } else {

        $scope.mode = 'new';
        $http.get('/sample_types/' + $scope.info.stid + '.json')
          .then(function(response) {
            $scope.sample = {
              name: "New sample type",
              description: "New sample type description",
              field_values: [],
              fields: {},              
              sample_type: response.data,
              sample_type_id: $scope.info.stid
            }
          });
      }

    });    

  }]);

})();
