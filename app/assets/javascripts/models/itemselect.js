(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.directive("itemselect", function() {

    return {

      restrict: 'A',

      scope: { ft: '=', operation: '=', fv: '=' },

      link: function($scope,$element,$attributes) {

        var ft = $scope.ft,
            fv = $scope.fv,
            route = $scope.operation.routing;

        var autocomp = function(ev,ui) {

          // Called when a sample input is updated. It checks for items
          // that match the given sample for every non-array input fv whose
          // routing matches matches the updated fv.

          var sid = AQ.id_from(ui.item.value);
          route[ft.routing] = ui.item.value;
          
          aq.each($scope.operation.operation_type.field_types,function(field_type) {

            aq.each($scope.operation.field_values, function(fv) {

              if ( ( (field_type.array && fv == $scope.fv ) || 
                    (!field_type.array && field_type.routing == ft.routing ) ) &&
                   field_type.matches(fv) && 
                   field_type.role == 'input' && 
                   $scope.operation.form.input[field_type.name] ) {

                var aft = $scope.operation.form.input[ft.name].aft;

                if ( aft.object_type_id ) {

                  fv.items = [];
                  fv.item = null;

                  AQ.items_for(sid,aft.object_type_id).then((items) => {            
                    if ( items.length > 0 ) {
                      fv.items = items;
                      fv.item = items[0];
                      $scope.$apply();
                    }
                  });

                }

              }

            });

          });

          $scope.$apply();

        };

        $scope.select = function(item) {
          fv.item = item;
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

        $scope.$watch('operation.form[ft.role][ft.name].aft', function(new_aft,old_aft) {
          if ( new_aft && new_aft.sample_type ) {
            var name = new_aft.sample_type.name;
            $($element).find("#sample-io").autocomplete({
              source: AQ.sample_names_for(name),
              select: autocomp
            });
            fv.items = [];
          }
        });

      },

      template: $('#item_select').html()

    }

  });
  
})();
