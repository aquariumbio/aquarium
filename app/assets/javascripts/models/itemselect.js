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

      scope: { ft: '=', operation: '=' },

      link: function($scope,$element,$attributes) {

        var ft = $scope.ft,
            io = $scope.operation[ft.role][ft.name],
            route = $scope.operation.routing;

        var autocomp = function(ev,ui) {

          var sid = AQ.id_from(ui.item.value);
          route[ft.routing] = ui.item.value;

          aq.each($scope.operation.operation_type.field_types,function(field_type) {

            var io = $scope.operation[field_type.role][field_type.name]; 

            if ( field_type.role == 'input' && field_type.routing == ft.routing ) {

              oid = io.aft.object_type_id;

              AQ.items_for(sid,oid).then((items) => {            
                if ( items.length > 0 ) {
                  io.items = items;
                  io.item = items[0];
                  $scope.$apply();
                }
              });

            }

          });

          $scope.$apply();

        };


        $scope.select = function(item) {
          io.item = item;
        }

        $scope.show_item_select = function(ft) {

          return ft.role == 'input' && 
            aq.where(
              ft.allowable_field_types,
              (aft) => { return aft.object_type_id != null }).length > 0;

        }

        $scope.$watch('operation[ft.role][ft.name].aft', function(new_aft,old_aft) {
          if ( new_aft ) {
            var name = new_aft.sample_type.name;
            $($element).find("#sample-io").autocomplete({
              source: AQ.sample_names_for(name),
              select: autocomp
            });
            io.items = [];
          }
        });

      },

      template: $('#item-select-template').html()

    }

  });
  
})();

