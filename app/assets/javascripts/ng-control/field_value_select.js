(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.directive("fv", function() {

    return {

      restrict: 'AE',

      scope: { fv: '=', plan: "=", operation: '=' },

      link: function($scope,$element,$attributes) {

        var fv = $scope.fv,
            ft = $scope.fv.field_type,
            op = $scope.operation,
            plan = $scope.plan,
            op_type = op.operation_type,
            route = op.routing;    

        var autocomp = function(ev,ui) {

          var sid = AQ.id_from(ui.item.value);

          // send new sid to i/o of other operations
          plan.propagate(op,fv,ui.item.value); 

          // use sample information to fill in inputs, if possible
          if ( fv.role == 'output' ) {
            op.instantiate(plan,fv,sid);
          }

          if ( ft.array ) {

            fv.sample_identifier = ui.item.value;

            var aft = op.form[fv.role][fv.name].aft;
            if ( aft.object_type_id ) {
              fv.clear();
              fv.find_items(sid);
            }               

          } else {

            route[ft.routing] = ui.item.value; // Updates other sample ids with same routing

            op.each_field((field_type,field_value) => {
              if ( field_type.routing == fv.routing && !field_type.array ) {
                var aft = op.form[field_value.role][field_value.name].aft;
                if ( aft.object_type_id ) {
                  field_value.clear();
                  field_value.find_items(sid);
                }               
              }
            });

          }

          $scope.$apply();

        }   

        $scope.$watch("operation.form[fv.field_type.role][fv.name].aft", function(new_aft, old_aft) {

          var aft = op.form[ft.role][fv.name].aft;

          if ( aft && aft.sample_type ) {

            var name = aft.sample_type.name;

            console.log("autocomplete for " + fv.name + " assigned")

            $($element).autocomplete({
              source: AQ.sample_names_for(name),
              select: autocomp
            });

            if ( !ft.array && new_aft && old_aft && ( 
                 new_aft.object_type_id != old_aft.object_type_id || 
                 new_aft.sample_type_id != old_aft.sample_type_id ) ) {
              fv.clear();
            }

          }

        });         

      }

    }

  });

})();
