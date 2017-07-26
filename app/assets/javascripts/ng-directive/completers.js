(function() {

  var w = angular.module('aquarium'); 

  w.directive("samplecomplete", function() {

    samples_for = function(names,types) {
      var samples = [];
      if ( types == "all" ) {
        for ( var type in names ) {
          samples = samples.concat(names[type]);
        }
      } else {
        aq.each(types,function(type) {
          samples = samples.concat(names[type])
        });
      }
      return samples;    
    }

    return {
      restrict: 'A',
      scope: { samplecomplete: '=', ngModel: '='  },
      link: function($scope,$element,$attributes) {

        var sample_names = $scope.$parent.sample_names;

        var types = $scope.samplecomplete;
        $($element).autocomplete({
          source: samples_for($scope.$parent.sample_names,types),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });

        function changed() {
          return sample_names != $scope.$parent.sample_names;
        }

        $scope.$watch(changed, function (v) {
          console.log("Updating samplecomplete")
          types = $scope.samplecomplete;
          sample_names = $scope.$parent.sample_names;
          $($element).autocomplete({
            source: samples_for($scope.$parent.sample_names,types),
            select: function(ev,ui) {
              $scope.ngModel = ui.item.value;
              $scope.$apply();
            }
          });
        });

      }
    }

  });

  w.directive("ftsamplecomplete", function() {

    samples_for = function(names,types) {
      var samples = [];
      if ( names ) {
        aq.each(types,function(type) {
          samples = samples.concat(names[type])
        });
      }
      return samples;
    }

    return {
      restrict: 'A',
      scope: { ftsamplecomplete: '=', ngModel: '=', aft: '=' },
      link: function($scope,$element,$attributes) {

        var types = [];

        if ( $scope.aft ) {
          types = [ $scope.aft.sample_type.name ];
        } else {
          types  = aq.collect(
                      aq.where(
                        $scope.ftsamplecomplete.allowable_field_types,
                        function(aft) { return aft.sample_type; }),
                      function(aft) { return aft.sample_type.name; });          
        }

        $element.autocomplete({
          source: samples_for($scope.$root.sample_names,types),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });
        
        $scope.$watch('aft', function (v) {
          if ( $scope.aft ) {
            types = [ $scope.aft.sample_type.name ];
            $($element).autocomplete({
              source: samples_for($scope.$root.sample_names,types),
              select: function(ev,ui) {
                $scope.ngModel = ui.item.value;
                $scope.$apply();
              }
            });
            $element.val("");
          }
        });

      }
    }

  });

  w.directive("projectcomplete", function() {

    return {
      restrict: 'A',
      scope: { ngModel: '=' },
      link: function($scope,$element,$attributes) {
        $($element).autocomplete({
          source: aq.collect($scope.$parent.projects,function(p) { return p.name; }),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });
      }
    }

  });  

  w.directive("sampletypecomplete", function() {

    return {
      restrict: 'A',
      scope: { ngModel: '=' },
      link: function($scope,$element,$attributes) {
        $($element).autocomplete({
          source: aq.collect($scope.$parent.sample_types,function(p) { return p.name; }),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });
      }
    }

  });   

  w.directive("objecttypecomplete", function() {

    return {
      restrict: 'A',
      scope: { objecttypecomplete: '=', ngModel: '=' },
      link: function($scope,$element,$attributes) {
        $($element).autocomplete({
          source: aq.collect(aq.where($scope.$parent.object_types,function(ot) { 
                    return ot.handler == "sample_container" || ot.handler == "collection"
                  }),function(p) { return p.name; }),
          select: function(ev,ui) {
            $scope.ngModel = ui.item.value;
            $scope.$apply();
          }
        });
      }
    }

  });   

})();
