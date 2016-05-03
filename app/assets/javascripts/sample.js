(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', []); 
  } 

  w.controller('sampleEditCtrl', [ '$scope', '$http', '$attrs', '$location', '$window', 
                        function (  $scope,   $http,   $attrs,   $location,   $window ) {

    $scope.info = {};
    $scope.sample = new Sample($http);
    $scope.helper = new SampleHelper($http);
    $scope.ready = false;
    $scope.errors = [];
    $scope.messages = [];

    if ( $window.location.search ) {
      $scope.messages.push(decodeURI($window.location.search.split('=')[1]));
    }

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

        $scope.sample.update(function(result) {
          if ( result.errors ) {
            $scope.errors = result.errors;
          } else {
            window.location = '/samples/' + result.sample.id + '/edit?message=Sample ' + result.sample.id + " saved.";
          }
        });

      } else {

        $scope.sample.create(function(result) {
          if ( result.errors ) {
            $scope.errors = result.errors;
          } else {
            window.location = '/samples/' + result.sample.id + '/edit?message=Sample ' + result.sample.id + " created.";
          }
        });

      }

    }

  }]);

})();
