(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace','ngMaterial']); 
  } 

  w.directive("sampleselect", function() {

    return {

      restrict: 'AE',

      scope: { ft: '=', plan: "=", operation: '=', fv: '=', focus: '=' },

      link: function($scope,$element,$attributes) {

        var ft = $scope.ft,
            fv = $scope.fv,
            op = $scope.operation,
            plan = $scope.plan,
            op_type = $scope.operation.operation_type,
            route = $scope.operation.routing;

        // Called when a sample input is updated. 
        var autocomp = function(ev,ui) {

          var sid = AQ.id_from(ui.item.value); 

          // send new sid to i/o of other operations
          plan.propagate(op,fv,ui.item.value); 
          op.update_cost();

          if ( ft.array ) {

            fv.sample_identifier = ui.item.value;

          } else {

            route[ft.routing] = ui.item.value; // Updates other sample ids with same routing

            op.each_field((field_type,field_value) => {

              if ( field_type.routing == fv.routing && !field_type.array ) {
                var aft = op.form[field_value.role][field_value.name].aft;
                if ( aft.object_type_id ) {
                  field_value.clear();
                  AQ.items_for(sid,aft.object_type_id).then((items) => { 
                    if ( items.length > 0 ) {                      
                      field_value.items = items;
                      field_value.selected_item = items[0];
                      field_value.sid = sid;
                      $scope.$apply();
                    }
                  });
                }               
              }

            });

          }

          $scope.$apply();

        };

        $scope.input_class = function() {
          var c = "sample-only";
          if ( fv.items.length > 0 ) {
            c += " input-satisfied";
          }
          return c
        }

        $scope.select = function(item) {
          fv.selected_item = item;
        }

        $scope.item_select_class = function(ft) {
          var c = "btn dropdown-toggle dropdown";
          if ( ft.array ) {
            c += " array-item-input";
          }
          return c;
        }

        $scope.show_item_select = function(ft) {

          return ft.role == 'input' && 
            aq.where(
              ft.allowable_field_types,
              (aft) => { return aft.object_type_id != null }
            ).length > 0;

        }

        $scope.$watch('operation.form[ft.role][ft.name].aft', 
                      function(new_aft,old_aft) {
          if ( new_aft && new_aft.sample_type ) {
            var name = new_aft.sample_type.name;
            $($element).find("#sample-io").autocomplete({
              source: AQ.sample_names_for(name),
              select: autocomp
            });
            fv.clear();
          }
        });    

      },

      template: $('#sample_select').html()

    }

  });
  
})();
