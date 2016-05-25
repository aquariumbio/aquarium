(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('sampleEditCtrl', [ '$scope', '$http', '$attrs', '$location', '$window', 
                        function (  $scope,   $http,   $attrs,   $location,   $window ) {

    $scope.info = {};
    $scope.sample = new Sample($http);
    $scope.helper = new SampleHelper($http);
    $scope.ready = false;
    $scope.errors = [];
    $scope.messages = [];
    $scope.mode = 'initilizing';
    $scope.changes = -2;

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

    $scope.$watch('sample', function() { 
      $scope.changes++;
    },true);    

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

        $scope.sample.update(function(result) {
          if ( result.save_error ) {
            $scope.errors = result.save_error;
          } else {
            $scope.errors = [];
            $scope.messages = [ 'Sample ' + result.id + " saved." ];
            $scope.changes = 0;
          }
        });

      } else {

        $scope.sample.create(function(result) {
          if ( result.save_error ) {
            $scope.errors = result.save_error;
          } else {
            window.location = '/samples/' + result.id + '/edit?message=Sample ' + result.id + " created.";
          }
        });

      }

    }

    $scope.legacy = function() {
      return $scope.sample.field1 || $scope.sample.field2 || $scope.sample.field3 || $scope.sample.field4
          || $scope.sample.field5 || $scope.sample.field6 || $scope.sample.field7 || $scope.sample.field8; 
    }

    $scope.eight = [ 1,2,3,4,5,6,7,8 ];

  }]);

})();