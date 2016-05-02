(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', []); 
  } 

  w.controller('sampleEditCtrl', [ '$scope', '$http', '$attrs', function ($scope,$http,$attrs,treeAjax) {

    $scope.info = {};
    $scope.sample = new Sample($http);
    $scope.helper = new SampleHelper($http);
    $scope.ready = false;
    $scope.errors = [];
    $scope.messages = [];

    $scope.helper.autocomplete(function(sample_names) {
      $scope.sample_names = sample_names;
      $scope.ready = true;
    });

    $scope.$watch('info', function () {

      if ( $scope.info.sid > 0 ) {
        $scope.sample.find($scope.info.sid, function(sample) {
          $scope.mode = 'edit';
        });
      } else {
        $scope.sample.new($scope.info.stid,function() {
          $scope.mode = 'new';
        });
      }

    });

    $scope.add_to_array = function(ft) {
      $scope.sample.field_values.push($scope.sample.sample_type.default_field(ft));
    } 

    $scope.remove_from_array = function(fv) {
      fv.deleted = true;
    }    

    $scope.clear_errors = function() {
      $scope.errors = [];
    }       

    $scope.clear_messages = function() {
      $scope.messages = [];
    }           

    $scope.save = function() {
      if ( $scope.mode == 'edit' ) {
        $scope.messages = [ "Saving edited samples not yet implemented." ];
      } else {
        $scope.sample.create(function(result) {
          if ( result.errors ) {
            $scope.errors = result.errors;
          } else {
            $scope.sample = new Sample($http).find(result.sample.id,function() {
              $scope.clear_errors();
              $scope.messages = [ "Created new sample. Id: " + result.sample.id ];
              $scope.mode = 'edit';
            });
          }
        });
      }
    }

  }]);

})();
