(function() {

  var w;

  try {
    w = angular.module('aquarium'); 
  } catch (e) {
    w = angular.module('aquarium', ['ngCookies','ui.ace']); 
  } 

  w.controller('viewEditPlanCtrl', [ '$scope', '$http', '$attrs', '$cookies', 
                          function (  $scope,   $http,   $attrs,   $cookies ) {


    $scope.user = new User($http); 

    $scope.node_class = function(plan,node) {
      var c = "node";
      if ( plan.current_node == node ) {
        c += " node-selected";
      } 
      if ( node.ready ) {
        c += " node-ready";
      }
      if ( node.status == 'unplanned' ) {
        c += " node-unplanned";
      }
      if ( node.problem ) {
        c += " node-problem";
      }
      return c;
    }

    $scope.select_node = function(plan,node) {
      plan.current_node = node;
    }

    function io_info(io,ot,role) {
      if (ot) {
        var fts = aq.where(ot.field_types,function(ft) {
          return ft.role == role && ft.name == io.name;
        });
        var aft = aq.where(fts[0].allowable_field_types,function(aft) {
          return !io.child_sample || ( io.child_sample && io.child_sample.sample_type_id == aft.sample_type_id );
        })[0];
        return aft;
      } else {
        return null;
      }
    }

    $scope.part = function (io,ot,role) {
      var fts = aq.where(ot.field_types,function(ft) {
        return ft.role == role && ft.name == io.name;
      });
      return fts.length > 0 && fts[0].part;
    }

    $scope.input_info = function(io,ot) {    
      return io_info(io,ot,'input');
    }

    $scope.output_info = function(io,ot) {    
      return io_info(io,ot,'output');
    }

    $scope.expand = function(op) {
      op.open = true;
    }

    $scope.unexpand = function(op) {
      op.open = false;
    }

    op_cost = function(op,status) {

      var c = 0.0;

      if ( status == "Under Construction" && op.nominal_cost ) {
        c += op.nominal_cost.materials + op.nominal_cost.labor;        
      } else if ( op.materials && op.labor ) {
        c += op.materials + op.labor;        
      }

      aq.each(op.predecessors,function(p) {
        aq.each(p.operations,function(op) {
          if ( op.selected ) {            
            c += op_cost(op,status);
          }
        });
      })

      return c;

    }

    $scope.cost = function(plan) {

      var cost = 0.0;

      aq.each(plan.goals,function(goal) {
        cost += op_cost(goal,plan.status);
      });

      return cost;

    }

    $scope.needs_more_planning = function(node) {
      return aq.where(node.predecessors, function(p) {
        return p.undetermined;
      }).length > 0;
    }    

  }]);

})();
