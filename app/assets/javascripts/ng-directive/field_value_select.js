(function() {

  var w = angular.module('aquarium'); 

  w.directive("fv", function() {

    return {

      restrict: 'AE',

      scope: { fv: '=', plan: "=", operation: '=' },

      link: function($scope,$element,$attributes) {

        var autocomp = function(ev,ui) {

          var fv = $scope.fv,
              ft = $scope.fv.field_type,
              op = $scope.operation,
              plan = $scope.plan,
              op_type = op.operation_type,
              route = op.routing;              

          // respond when a new sample is chosen from the autocomplete

          var sid = ui.item.value;

          // console.log("autocomp " + sid)

          AQ.Sample
            .find_by_identifier(sid)
            .then(sample => plan.assign(fv, sample))
            .then(plan => plan.choose_items())
            .then(plan => $scope.$apply())

        }  

        var change = function(ev,ui)  {

          var fv = $scope.fv,
              ft = $scope.fv.field_type,
              op = $scope.operation,
              plan = $scope.plan,
              op_type = op.operation_type,
              route = op.routing;            

          var sid = ft.array ? fv.sample_identifier : route[ft.routing];
              aft = op.form[ft.role][fv.name].aft;

          if ( aft && aft.sample_type && !AQ.sample_names_for(aft.sample_type.name).includes(sid) ) {
            console.log("Invalid sample name: " + sid)
            op.assign_sample(fv, null);
            op.instantiate(plan,fv,null);
            fv.clear_item(); 
            fv.items=[];
            $scope.$apply();
          }

        }

        $scope.$watch("operation.form[fv.field_type.role][fv.name].aft", function(new_aft, old_aft) {

          // Update autocomplete when aft changes

          var fv = $scope.fv,
              ft = $scope.fv.field_type,
              op = $scope.operation,
              plan = $scope.plan,
              op_type = op.operation_type,
              route = op.routing;            

          var aft = op.form[ft.role][fv.name].aft;                          

          if ( aft && aft.sample_type ) {

            var name = aft.sample_type.name;

            $($element).autocomplete({

              source: AQ.sample_names_for(name),

              select: autocomp,

              change: change,

              open: function(event, ui) {
              
                  var $input = $(event.target),
                      $results = $input.autocomplete("widget"),
                      desiredHeight = 300,
                      newTop = - desiredHeight + $input.offset().top - 10;

                   $results.css("width", $input.width())
                           .css("overflow", "scroll")
                           .css("height", desiredHeight + "px")
                           .css("position", "absolute")
                           .css("top", newTop + "px");
              }

            });

            if ( new_aft && old_aft && ( 
                 new_aft.object_type_id != old_aft.object_type_id || 
                 new_aft.sample_type_id != old_aft.sample_type_id ) ) {
              fv.clear_item();
              fv.items = [];
            }

          }

        });         

      }

    }

  });

})();
