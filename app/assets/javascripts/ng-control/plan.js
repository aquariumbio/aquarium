(function() {

  var w = angular.module('aquarium'); 

  w.controller('planCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', 
                  function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }
    AQ.sce = $sce;

    $scope.snap = 16;
    $scope.last_place = 0;
    $scope.plan = AQ.Plan.record({operations: [], wires: [], status: "planning", name: "Untitled Plan"});
    $scope.multiselect = {};

    $scope.ready = false;

    $scope.state = {}

    AQ.User.current().then((user) => {

      $scope.current_user = user;
      $scope.getting_plans = true;    

      AQ.OperationType.all_with_content(true).then((operation_types) => {

        $scope.operation_types = aq.where(operation_types,ot => ot.deployed);
        AQ.OperationType.compute_categories($scope.operation_types);
        AQ.operation_types = $scope.operation_types;

        AQ.Plan.where({status: "planning", user_id: user.id}).then(plans => {

          $scope.plans = plans;

          AQ.get_sample_names().then(() =>  {
            $scope.ready = true;
            $scope.$apply();
          });  

        });

      });
    });
    
    // Actions ////////////////////////////////////////////////////////////////////////////////////

    function all_ops(f) {
      aq.each($scope.plan.operations,f);
    }

    function refresh_plan_list() {
      AQ.Plan.where({status: "planning", user_id: $scope.current_user.id}).then(plans => { 
        $scope.state.loading_plans = false;
        $scope.plans = plans;
      });
    }

    $scope.add_operation = function(ot) {
      var op = AQ.Operation.record({
        x: 3*$scope.snap + $scope.last_place, 
        y: 2*$scope.snap + $scope.last_place, 
        width: 160, 
        height: 30,
        routing: {}, form: { input: {}, output: {} }
      });
      $scope.last_place += 4*$scope.snap;
      op.set_type(ot);
      $scope.current_op = op;
      $scope.plan.operations.push(op);
      $scope.set_current_fv(op.field_values[0],true);
    }

    $scope.add_predecessor = function(fv,op,pred) {

      var newop = $scope.plan.add_wire_from(fv,op,pred);
      $scope.plan.wires[$scope.plan.wires.length-1].snap = $scope.snap;
      newop.x = op.x;
      newop.y = op.y + 4*$scope.snap;
      newop.width = 160;
      newop.height = 30;

      select(newop);
      var inputs = aq.where(newop.field_values, fv => fv.role == 'input');
      if ( inputs.length > 0 ) {
        $scope.set_current_fv(inputs[0]);
      }

    }

    $scope.add_successor = function(fv,op,suc) {

      var newop = $scope.plan.add_wire_to(fv,op,suc);
      $scope.plan.wires[$scope.plan.wires.length-1].snap = $scope.snap;
      newop.x = op.x;
      newop.y = op.y - 4*$scope.snap;
      newop.width = 160;
      newop.height = 30;

      select(newop);
      var fvs = aq.where(newop.field_values, fv => fv.role == 'output');
      if ( fvs.length > 0 ) {
        $scope.set_current_fv(fvs[0]);
      }

    }    

    function select(object) {
      $scope.state.launch = false;
      $scope.current_op   = object && object.model.model == "Operation"  ? object : null;
      $scope.current_fv   = object && object.model.model == "FieldValue" ? object : null;
      $scope.current_wire = object && object.model.model == "Wire"       ? object : null;
    }

    $scope.set_current_fv = function(fv,focus) {
      $scope.current_fv = fv;
      if ( focus ) { 
        setTimeout(function() { 
          var el = document.getElementById('fv-'+fv.rid);
          if ( el ) { el.focus() }
        }, 30);
      }
    }

    function op_in_multiselect(op) {

      var m = $scope.multiselect;

      return  (( m.width >= 0 && m.x < op.x && op.x + op.width < m.x+m.width ) ||
               ( m.width <  0 && m.x + m.width < op.x && op.x + op.width < m.x )) &&
              (( m.height >= 0 && m.y < op.y && op.y + op.height < m.y+m.height ) ||
               ( m.height <  0 && m.y + m.height < op.y && op.y + op.height < m.y ));

    }

    $scope.note = function(msg) {
      console.log(msg);
    }

    $scope.save = function(plan) {
      plan.save().then(saved_plan => {
        $scope.plan = saved_plan;
        $scope.state.loading_plans = true;
        select(null);
        $scope.$apply();
        refresh_plan_list();
      });

    }

    $scope.delete_plan = function(p) {

      $scope.new();
      $scope.state.deleting_plan = p;
      p.destroy().then(() =>  refresh_plan_list());

    }

    $scope.load = function(plan) {

      AQ.Plan.load(plan.id).then(p => {
        $scope.plan = p;
        $scope.$apply();
      })

    }

    $scope.new = function() {
      $scope.plan = AQ.Plan.record({operations: [], wires: [], status: "planning", name: "Untitled Plan"});
      select(null)
    }    

    $scope.select_uba= function(user,s) {      
      aq.each(user.user_budget_associations, uba => {
        if ( uba.id == s.id ) {
          uba.selected = true;
          $scope.plan.uba = uba;
        } else {
          uba.selected = false;
        }
      });
    }

    $scope.launch = function() {

      select(null)
      $scope.state.launch = true;
      $scope.plan.uba = null;
      aq.each($scope.current_user.user_budget_associations, uba => uba.selected = false);

      $scope.plan.save().then(saved_plan => {
        $scope.plan = saved_plan;
        $scope.plan.estimate_cost(); 
      });
      
    }

    $scope.submit_plan = function() {
      $scope.state.planning = true;
      $scope.plan.submit().then(() => {
        $scope.state.planning = false;
        $scope.state.submitted_plan = $scope.plan;
        $scope.new();
        $scope.state.launch = false;
        refresh_plan_list();
      }).catch(errors => {
        console.log(errors);
        $scope.state.planning = false;        
        $scope.plan.errors = errors;
        $scope.$apply();
      })
    }

    // Main Events ////////////////////////////////////////////////////////////////////////////////

    $scope.mouseDown = function(evt) {

      select(null);
      all_ops(op => op.multiselect = false);

      $scope.multiselect = {
        x: evt.offsetX,
        y: evt.offsetY,
        width: 0,
        height: 0,
        active: true,
        dragging: false
      }      

    }

    $scope.mouseMove = function(evt) {

      if ( $scope.current_op && $scope.current_op.drag ) {

        $scope.current_op.x = evt.offsetX - $scope.current_op.drag.localX;
        $scope.current_op.y = evt.offsetY - $scope.current_op.drag.localY;
        $scope.last_place = 0;

      } else if ( $scope.multiselect.dragging ) {

        all_ops(op => {
          if ( op.multiselect ) {
            op.x = evt.offsetX - op.drag.localX;
            op.y = evt.offsetY - op.drag.localY;
          }
        });

      } else if ( $scope.multiselect.active ) {

        $scope.multiselect.width = evt.offsetX - $scope.multiselect.x;
        $scope.multiselect.height = evt.offsetY - $scope.multiselect.y;

      }

    }    

    $scope.mouseUp = function(evt) {

      if ( $scope.multiselect.dragging ) {
        $scope.multiselect.dragging = false;
      } else if ( $scope.multiselect.active  ) {
        all_ops(op => {
          if ( op_in_multiselect(op) ) {
            op.multiselect = true;
          }
        });
        $scope.multiselect.active = false;        
      }
    }

    $scope.keyDown = function(evt) {

      switch(evt.key) {

        case "Backspace": 
        case "Delete":

          if ( $scope.current_wire ) {
            $scope.plan.remove_wire($scope.current_wire);
            $scope.current_wire = null;
          }
          if ( $scope.current_op && !$scope.current_fv ) {
            aq.remove($scope.plan.operations, $scope.current_op);                               
            $scope.plan.wires = aq.where($scope.plan.wires, w => {
              var remove = w.to_op == $scope.current_op || w.from_op == $scope.current_op;
              if ( remove ) {
                w.disconnect();
              }              
              return !remove;
            });
            $scope.current_op = null;
          }
          break;

        case "Escape":
          select(null);
          all_ops(op => op.multiselect = false)
          break;

        case "A":
        case "a":
          all_ops(op => op.multiselect = true );
          select(null);
          break


        default:

      }

    }    

    // Operation Events //////////////////////////////////////////////////////////////////////////    

    $scope.opMouseDown = function(evt,op) {

      if ( op.multiselect ) {

        all_ops(op => {
          if ( op.multiselect ) {
            op.drag = {
              localX: evt.offsetX - op.x, 
              localY: evt.offsetY - op.y
            }
          }
        });

        $scope.multiselect.dragging = true;

      } else {

        select(op); 
        all_ops(op=>op.multiselect=false);
        $scope.current_op.drag = {
          localX: evt.offsetX - op.x, 
          localY: evt.offsetY - op.y
        };   

      }

      evt.stopImmediatePropagation();

    }

    function snap(op) {
      op.x = Math.floor((op.x+$scope.snap/2) / $scope.snap) * $scope.snap;
      op.y = Math.floor((op.y+$scope.snap/2) / $scope.snap) * $scope.snap;      
    }

    $scope.opMouseUp = function(evt,op) {

      if ( op.multiselect ) {
        aq.each($scope.plan.operations, op => snap(op));
        delete op.drag;
      } else {
        snap(op);
        delete op.drag;
      }        
      
    }

    $scope.opMouseMove = function(evt,op) {}

    // Field Value Events ///////////////////////////////////////////////////////////////////////

    $scope.fvMouseDown = function(evt,op,fv) {

      all_ops(op=>op.multiselect=false);

      if ( $scope.current_fv && evt.shiftKey ) { // There is an fv already selected, so make a wire

        var wire;

        if ( $scope.current_fv.role == 'output' && $scope.current_fv.field_type.can_produce(fv) ) {

          if ( $scope.plan.reachable(fv, $scope.current_fv) ) {

            alert("Cyclic plans are not currently supported. Cannot add wire.")

          } else {

            wire = AQ.Wire.make({
              from_op: $scope.current_op,
              from: $scope.current_fv,
              to_op: op,
              to: fv,
              snap: $scope.snap
            });

            $scope.plan.wires.push(wire);            

          }

        } else if ( fv.field_type.can_produce($scope.current_fv) ) {

          if ($scope.plan.reachable($scope.current_fv,fv)) {

            alert("Cyclic plans are not currently supported. Cannot add wire.")            

          } else {

            wire = AQ.Wire.make({
              to_op: $scope.current_op,
              to: $scope.current_fv,
              from_op: op,
              from: fv,
              snap: $scope.snap
            });

            $scope.plan.wires.push(wire);            

          }

        }

      } else {

        select(op);
        $scope.set_current_fv(fv,true);

      }

      evt.stopImmediatePropagation();

    }    

    // Wire Events ////////////////////////////////////////////////////////////////////////////////

    $scope.wireMouseDown = function(evt, wire) {
      select(wire);
      evt.stopImmediatePropagation();  
    }

    // Computed Classes ///////////////////////////////////////////////////////////////////////////

    $scope.op_class = function(op) {
      var c = "op";
      if ( op == $scope.current_op || op.multiselect ) {
        c += " op-selected";
      }
      return c;
    }

    $scope.io_class = function(op,fv) {

      var c = "field-value";

      if ( $scope.current_fv && 
           $scope.current_fv.role == 'input' && 
           fv.role == 'output' && 
           fv.field_type.can_produce($scope.current_fv) ) {

        c += " field-value-compatible";

      } else if ( $scope.current_fv && 
                  $scope.current_fv.role == 'output' && 
                  fv.role == 'input' && 
                  $scope.current_fv.field_type.can_produce(fv) ) {

        c += " field-value-compatible";

      } else if ( fv.valid() ) {
        c += " field-value-valid";
      } else {
        c += " field-value-invalid";
      }

      return c;

    }

    $scope.parameter_class = function(op, fv) {
      var c = "parameter";
      if ( fv.value != undefined ) {
        c += " parameter-has-value";
      } else {
        c += " parameter-has-no-value";
      };
      return c;
    }

    $scope.multiselect_x = function() {
      return $scope.multiselect.width > 0 ? $scope.multiselect.x : $scope.multiselect.x + $scope.multiselect.width;
    }

    $scope.multiselect_y = function() {
      return $scope.multiselect.height > 0 ? $scope.multiselect.y : $scope.multiselect.y + $scope.multiselect.height;
    }    

    $scope.multiselect_width = function() {
      return Math.abs($scope.multiselect.width);
    }

    $scope.multiselect_height = function() {
      return Math.abs($scope.multiselect.height);
    }

    // Inventory ////////////////////////////////////////////////////////////////////////////////////
    $scope.select_item = function(fv, item) {

      if ( fv.child_item_id != item.id && item.assign_first ) {
        item.assign_first(fv);
      }

      fv.child_item_id = item.id;
      fv.child_item = item;

    }

    $scope.select_row_column = function(fv,sid,collection,r,c) {      
      if ( fv.sid == sid ) {
        console.log(["selecting", fv, collection, r, c])
        fv.child_item_id = collection.id;
        fv.child_item = collection;
        fv.row = r;
        fv.column = c;
        console.log(["changed", fv.rid, fv.child_item_id, fv.row, fv.column])
      }
    }

    $scope.io_focus = function(op,ft,fv) {
    }    

    // Operation type selection ///////////////////////////////////////////////////////////////////////
    $scope.choose_category = function(category) {
      $scope.state.category_index = $scope.operation_types.categories.indexOf(category);
    }

    // Wires //////////////////////////////////////////////////////////////////////////////////////////

    $scope.remove_orphan_wires = function() {
      var list = []
      aq.each($scope.plan.wires, wire => {
        if ( wire.from.deleted || wire.to.deleted ) {
          list.push(wire);
        }
      });
      aq.each(list,wire => {
        aq.remove($scope.plan.wires,wire);
      })
    }

  }]);

  w.directive('wrapper', [

    function() {

      return {

        restrict: 'C',

        link: function(scope, element) {

          var innerElement = element.find('inner');

          scope.$watch(
            function() {
              return innerElement[0].offsetHeight;
            },
            function(value, oldValue) {
              setTimeout(function() {
                element.css('height', innerElement[0].offsetHeight+'px');
                scope.status = innerElement[0].offsetHeight;
              }, 30);
            }, true);

        }

      };

    }

  ]);

})();                    
