(function() {

  var w;
  try {
    w = angular.module('workflow'); 
  } catch (e) {
    w = angular.module('workflow', []); 
  }  

  var containers;

  $.ajax({
    url: '/containers_list.json'
  }).done(function(data) {
    containers = data;
  });

  var sample_types;

  $.ajax({
    url: '/sample_types_list.json'
  }).done(function(data) {
    sample_types = data;
  });  

  w.directive("alternatives", function() {

    return {
      restrict: 'A',
      scope: { alternatives: "=" },
      templateUrl: "/workflow/editor/alternatives.html"
    }

  });  

  w.directive("alternative", function() {

    return {
      restrict: 'A',
      link: function($scope,$element) {

        // Disable if non-native operation
        if ( $scope.$parent.$parent.disabled() ) {
          $element.find('input').attr('disabled',true);
        }

        // Autocompletes
        $scope.$watch(
          function() { return $scope.alternative; },
          function() {

            $element.find(".container").autocomplete({
              source: containers,
              select: function(ev,ui) {
                $scope.alternative.container = ui.item.value;
                $scope.$apply();
              }
            });

            function sample_autocomplete() {
              var st_id = $scope.alternative.sample_type.split(':')[0];
              $.ajax({
                url: '/sample_list/' + st_id + ".json"
              }).done(function(samples) {
                $element.find(".sample").autocomplete({
                  source: samples,
                  select: function(ev,ui) {
                    $scope.alternative.sample = ui.item.value;
                    $scope.$apply();
                  }
                });
              });
            }

            sample_autocomplete();

            $element.find(".sample_type").autocomplete({
              source: sample_types,
              select: function(ev,ui) {
                // update model
                $scope.alternative.sample_type = ui.item.value;
                $scope.$apply();
                // restrict samples autocomplete
                sample_autocomplete();
              }
            });

          }
        );
      }
    }

  });    

  w.directive("ispec", function() {

    return {

      restrict: 'A',
      scope: { ispec: "=", ex: "=", oper: "=", partType: "=" },
      require: "^ngController",
      link: function($scope,$element,$attr,wfCtrl) {

        $scope.disabled = function() {
          return $scope.$parent.$parent.h.operation.workflow != wfCtrl.get_id();
        }

        // Disable if non-native
        if ( $scope.disabled() ) {
          $element.find('input').attr('disabled',true);
          $element.find('textarea').attr('disabled',true);          
        }

        // Dimensions //////////////////////////////////////////////////////////////////////

        $scope.dimensions = function() {
          if ( !$scope.ispec.rows ) {
            $scope.ispec.rows = 1;
          }
          if ( !$scope.ispec.columns ) {
            $scope.ispec.columns = 1;
          }           
        }

        // Alternatives ////////////////////////////////////////////////////////////////////

        $scope.new_alternative = function() {
          $scope.ispec.alternatives.push({});
        }        

        $scope.delete_alternative = function(alternative) {
          aq.delete_from_array($scope.ispec.alternatives,alternative);
        }      

      },

      templateUrl: "/workflow/editor/ispec.html" 

    };                                           

  });    

})();