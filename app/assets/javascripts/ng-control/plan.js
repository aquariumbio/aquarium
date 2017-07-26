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
    $scope.plan = AQ.Plan.record({operations: [], wires: []});
    $scope.multiselect = {};

    $scope.ready = false;

    AQ.User.current().then((user) => {

      $scope.current_user = user;
      $scope.getting_plans = true;    

      AQ.OperationType.all_with_content(true).then((operation_types) => {

        $scope.operation_types = aq.where(operation_types,ot => ot.deployed);
        AQ.OperationType.compute_categories($scope.operation_types);
        AQ.operation_types = $scope.operation_types;

        AQ.get_sample_names().then(() =>  {
          $scope.ready = true;
          $scope.$apply();
        });        
      });
    });
    
    // Actions ////////////////////////////////////////////////////////////////////////////////////

    function all_ops(f) {
      aq.each($scope.plan.operations,f);
    }

    $scope.add_operation = function(ot) {
      var op = AQ.Operation.record({
        x: 3*$scope.snap + $scope.last_place, y: 2*$scope.snap + $scope.last_place, width: 160, height: 30,
        routing: {}, form: { input: {}, output: {} }
      });
      $scope.last_place += 2*$scope.snap;
      op.set_type(ot);
      $scope.current_op = op;
      $scope.plan.operations.push(op);
      $scope.set_current_fv(op.field_values[0],true)
    }

    $scope.add_predecessor = function(fv,op,pred) {
      var newop = $scope.plan.add_wire(fv,op,pred);
      extend_wire($scope.plan.wires[$scope.plan.wires.length-1]);
      newop.x = op.x;
      newop.y = op.y + 4*$scope.snap;
      newop.width = 160;
      newop.height = 30;
      select(newop);
      var fvs = aq.where(newop.field_values, fv => fv.role == 'input');
      if ( fvs.length > 0 ) {
        $scope.set_current_fv(fvs[0]);
      }
    }

    function select(object) {
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

          if ( $scope.current_wire ) {
            $scope.plan.remove_wire($scope.current_wire);
            $scope.current_wire = null;
          }
          if ( $scope.current_op && !$scope.current_fv ) {
            aq.remove($scope.plan.operations, $scope.current_op);                      
            $scope.plan.wires = aq.where($scope.plan.wires, w => {
              return w.to_op != $scope.current_op && w.from_op != $scope.current_op;
            });
            $scope.current_op = null;
          }
          break;

        case "Escape":
          select(null);
          all_ops(op => op.multiselect = false)
          break;


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

        $scope.current_fv.wired = true;
        fv.wired = true;
        var wire;

        if ( $scope.current_fv.role == 'output' && $scope.current_fv.field_type.can_produce(fv) ) {

          wire = AQ.Wire.record({
            from_op: $scope.current_op,
            from_id: $scope.current_fv.rid,
            from: $scope.current_fv,
            to_op: op,
            to_id: fv.rid,
            to: fv
          });

        } else if ( fv.field_type.can_produce($scope.current_fv) ) {

          wire = AQ.Wire.record({
            to_id: $scope.current_fv.rid,
            to_op: $scope.current_op,
            to: $scope.current_fv,
            from_id: fv.rid,
            from_op: op,
            from: fv
          });

        }

        $scope.plan.wires.push(extend_wire(wire));

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
      console.log(wire);       
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

      if ( $scope.current_fv && $scope.current_fv.role == 'input' && fv.role == 'output' && fv.field_type.can_produce($scope.current_fv) ) {

        c += " field-value-compatible";

      } else if ( $scope.current_fv && $scope.current_fv.role == 'output' && fv.role == 'input' && $scope.current_fv.field_type.can_produce(fv)) {

        c += " field-value-compatible";

      } else {

        if ( fv.routing && op.routing[fv.routing] != "" ) { // Has a sample associated with it
          c += " field-value-with-sample";
        } else if ( fv.field_type.array && fv.sample_identifier && fv.sample_identifier != "" ) {
          c += " field-value-with-sample";
        }

        if ( !fv.wired && fv.role == 'input' && fv.items != "" ) { // Has items associated with it
          c += " field-value-with-items";
        }      

        if ( !fv.wired && fv.role == 'input' && fv.items == "" ) { // Has no items associated with it, but should
          c += " field-value-with-no-items";
        }      

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
      aq.each(fv.items, i => {
        if ( i.collection ) {
          i.selected = (i.collection.id == item.collection.id);
        } else {
          i.selected = (i.id == item.id);        
        }
      });
      fv.selected_item = item;
      fv.selected_row = item.selected_row;
      fv.selected_column = item.selected_column;
    }

    $scope.io_focus = function(op,ft,fv) {
    }    

    function extend(obj,name,method) {
      Object.defineProperty(obj,name,{ get: method, configurable: true});      
    }

    // Wires //////////////////////////////////////////////////////////////////////////////////////////

    function extend_wire ( wire ) {

      extend(wire,"x0", () => wire.from_op.x + wire.from_op.width/2 + (wire.from.index - wire.from_op.num_outputs/2.0 + 0.5)*$scope.snap );
      extend(wire,"y0", () => wire.from_op.y );
      extend(wire,"x1", () => wire.to_op.x + wire.to_op.width/2 + (wire.to.index - wire.to_op.num_inputs/2.0 + 0.5)*$scope.snap );
      extend(wire,"y1", () => wire.to_op.y + wire.to_op.height );

      extend(wire,"ymid", () => { 
        if ( !wire.ymid_frac ) { wire.ymid_frac = 0.5; }
        return wire.ymid_frac*(wire.y0 + wire.y1);
      });

      extend(wire,"xmid", () => { 
        if ( !wire.xmid_frac ) { wire.xmid_frac = 0.5; }
        return wire.xmid_frac*(wire.x0 + wire.x1);
      });      

      extend(wire,"yint0", () => { 
        return wire.y0 - $scope.snap;
      });       

      extend(wire,"yint1", () => { 
        return wire.y1 + $scope.snap;
      });           

      extend(wire,"path", () => {

        if ( wire.y0 >= wire.y1 + 2 * $scope.snap ) {

          return ""   + wire.x0 + "," + wire.y0 + 
                 " "  + wire.x0 + "," + wire.ymid + 
                 " "  + wire.x1 + "," + wire.ymid +    
                 " "  + wire.x1 + "," + wire.y1;

         } else {

          return ""   + wire.x0   + "," + wire.y0 + 
                 " "  + wire.x0   + " " + wire.yint0 +           
                 " "  + wire.xmid + "," + wire.yint0 + 
                 " "  + wire.xmid + "," + wire.yint1 +   
                 " "  + wire.x1   + "," + wire.yint1 +                 
                 " "  + wire.x1   + "," + wire.y1;          

         }

      }); 

      extend(wire,"arrowhead", () => {

        return "M "  + wire.x1 + " " + (wire.y1 + 5) + 
               " L " + (wire.x1 + 0.25*$scope.snap) + " " + (wire.y1 + 0.75*$scope.snap) + 
               " L " + (wire.x1 - 0.25*$scope.snap) + " " + (wire.y1 + 0.75*$scope.snap) + " Z";

      });

      return wire;

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
              element.css('height', value+'px');
              scope.status = value;
            }, true);

        }

      };

    }

  ]);

})();                    
