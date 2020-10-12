function PlanMouse($scope, $http, $attrs, $cookies, $sce, $window) {
  function all_draggable(f) {
    aq.each($scope.plan.operations, f);
    aq.each($scope.plan.modules, f);
    aq.each($scope.plan.current_module.input, f);
    aq.each($scope.plan.current_module.output, f);
    aq.each($scope.plan.current_module.text_boxes, f);
  }

  function current_draggable(f) {
    aq.each(
      aq.where(
        $scope.plan.operations,
        op => op.parent_id == $scope.plan.current_module.id
      ),
      f
    );
    aq.each(
      aq.where(
        $scope.plan.modules,
        m => m.parent_id == $scope.plan.current_module.id
      ),
      f
    );
    aq.each($scope.plan.current_module.input, f);
    aq.each($scope.plan.current_module.output, f);
    aq.each($scope.plan.current_module.text_boxes, f);
  }

  function draggable_in_multiselect(obj) {
    var m = $scope.multiselect;

    return (
      (obj.parent_id == $scope.plan.current_module.id ||
        obj.record_type == "ModuleIO" ||
        obj.record_type == "TextBox") &&
      ((m.width >= 0 && m.x < obj.x && obj.x + obj.width < m.x + m.width) ||
        (m.width < 0 && m.x + m.width < obj.x && obj.x + obj.width < m.x)) &&
      ((m.height >= 0 && m.y < obj.y && obj.y + obj.height < m.y + m.height) ||
        (m.height < 0 && m.y + m.height < obj.y && obj.y + obj.height < m.y))
    );
  }

  function snap(obj) {
    let snap = AQ.snap / 2;
    obj.x = Math.floor((obj.x + snap / 2) / snap) * snap;
    obj.y = Math.floor((obj.y + snap / 2) / snap) * snap;
  }

  $scope.multiselect = {};

  $scope.clear_multiselect = function() {
    all_draggable(obj => (obj.multiselect = false));
    $scope.multiselect = {};
  };

  function draggables() {
    return $scope.plan.operations.concat(
      $scope.plan.modules,
      $scope.plan.current_module.input,
      $scope.plan.current_module.output,
      $scope.plan.current_module.text_boxes
    );
  }

  $scope.multiple_objects_selected = function() {
    return aq.where(draggables(), op => op.multiselect).length != 0;
  };

  $scope.clear_operation_selects = function() {
    aq.each($scope.plan.operations, op => (op.edit_status = false));
  };

  // Global mouse events ////////////////////////////////////////////////////////////////////////

  $scope.mouseDown = function(evt) {
    $scope.select(null);
    $scope.clear_multiselect();

    $scope.multiselect = {
      x: evt.offsetX,
      y: evt.offsetY,
      width: 0,
      height: 0,
      active: true,
      dragging: false
    };

    $scope.clear_operation_selects();
  };

  $scope.mouseMove = function(evt) {
    if (
      $scope.current_draggable &&
      $scope.current_draggable.drag &&
      !$scope.current_fv &&
      // && the current draggable is not the module containing on of its selected io block
      !(
        $scope.current_draggable.record_type == "Module" &&
        $scope.current_draggable.io.includes($scope.current_io)
      )
    ) {
      $scope.current_draggable.x = Math.max(
        10,
        evt.offsetX - $scope.current_draggable.drag.localX
      );
      $scope.current_draggable.y = Math.max(
        10,
        evt.offsetY - $scope.current_draggable.drag.localY
      );
      $scope.last_place = 0;
    } else if ($scope.multiselect.dragging) {
      current_draggable(obj => {
        if (obj.multiselect) {
          obj.x = Math.max(10, evt.offsetX - obj.drag.localX);
          obj.y = Math.max(10, evt.offsetY - obj.drag.localY);
        }
      });
    } else if ($scope.multiselect.active) {
      $scope.multiselect.width = evt.offsetX - $scope.multiselect.x;
      $scope.multiselect.height = evt.offsetY - $scope.multiselect.y;
    }
  };

  $scope.mouseUp = function(evt) {
    if ($scope.multiselect.dragging) {
      $scope.multiselect.dragging = false;
    } else if ($scope.multiselect.active) {
      current_draggable(obj => {
        if (draggable_in_multiselect(obj)) {
          obj.multiselect = true;
        }
      });
      // console.log(aq.where($scope.plan.operations, op => op.multiselect))
      $scope.multiselect.active = false;
    }
  };

  // Draggable Object Events ////////////////////////////////////////////////////////////////

  $scope.draggableMouseDown = function(evt, obj) {
    if (obj.multiselect && obj.type != "TextBoxAnchor") {
      current_draggable(obj => {
        if (obj.multiselect) {
          obj.drag = {
            localX: evt.offsetX - obj.x,
            localY: evt.offsetY - obj.y
          };
        }
      });

      $scope.multiselect.dragging = true;
    } else {
      $scope.select(null);
      $scope.select(obj);

      all_draggable(d => (d.multiselect = false));

      $scope.current_draggable.drag = {
        localX: evt.offsetX - obj.x,
        localY: evt.offsetY - obj.y
      };
    }

    evt.stopImmediatePropagation();
  };

  $scope.draggableMouseUp = function(evt, obj) {
    if (obj.multiselect) {
      current_draggable(obj => snap(obj));
      delete obj.drag;
    } else {
      snap(obj);
      delete obj.drag;
    }
  };

  $scope.draggableMouseMove = function(evt, obj) {};

  $scope.multiselect_x = function() {
    return $scope.multiselect.width > 0
      ? $scope.multiselect.x
      : $scope.multiselect.x + $scope.multiselect.width;
  };

  $scope.multiselect_y = function() {
    return $scope.multiselect.height > 0
      ? $scope.multiselect.y
      : $scope.multiselect.y + $scope.multiselect.height;
  };

  $scope.multiselect_width = function() {
    return Math.abs($scope.multiselect.width);
  };

  $scope.multiselect_height = function() {
    return Math.abs($scope.multiselect.height);
  };

  // Field Value Events ///////////////////////////////////////////////////////////////////////

  $scope.ioMouseDown = function(evt, obj, io, role) {
    all_draggable(d => (d.multiselect = false));

    if ($scope.current_io && evt.shiftKey) {
      // There is an io already selected, so make a wire

      $scope.connect($scope.current_io, $scope.current_draggable, io, obj);
    } else {
      if (io.record_type == "FieldValue") {
        $scope.select(obj);
        $scope.set_current_io(io, true);
      } else if (io.record_type == "ModuleIO") {
        $scope.current_draggable = obj;
        $scope.current_op = null;

        if ((io.origin && io.origin.io) || io.destinations.length > 0) {
          $scope.set_current_io(io, true, role);
        } else {
          $scope.set_current_io(io, false, role);
        }
      }
    }

    evt.stopImmediatePropagation();
  };

  $scope.statusMouseDown = function(evt, op) {
    op.edit_status = !op.edit_status;
    evt.stopImmediatePropagation();
  };

  // Wire Events //////////////////////////////////////////////////////////////////////////

  $scope.wireMouseDown = function(evt, wire) {
    $scope.select(wire);
    evt.stopImmediatePropagation();
  };

  // Keyboard

  $scope.select_all = function() {
    current_draggable(obj => (obj.multiselect = true));
    $scope.select(null);
  };

  $scope.delete = function() {
    if ($scope.current_wire && $scope.current_wire.record_type == "Wire") {
      $scope.plan.remove_wire($scope.current_wire);
      $scope.current_wire = null;
      $scope.plan.base_module.associate_fvs();
    } else if (
      $scope.current_wire &&
      $scope.current_wire.record_type == "ModuleWire"
    ) {
      var old_wires = $scope.plan.get_implied_wires();
      $scope.plan.current_module.remove_wire($scope.current_wire);

      $scope.current_wire = null;
      $scope.plan.base_module.associate_fvs();
      $scope.plan.delete_obsolete_wires(old_wires);
      $scope.plan.recount_fv_wires();
    } else if ($scope.current_draggable && !$scope.current_fv) {
      if ($scope.current_draggable.record_type == "Module") {
        if ($scope.current_draggable.deletable($scope.plan)) {
          $scope.confirm_delete().then(() => {
            $scope.delete_object($scope.current_draggable);
            $scope.$apply();
          });
        } else {
          alert(
            "Module cannot be deleted because it contains active operations."
          );
        }
      } else {
        $scope.delete_object($scope.current_draggable);
      }
    } else if ($scope.multiselect) {
      var objects = [];

      current_draggable(obj => {
        if (obj.multiselect) {
          objects.push(obj);
        }
      });

      $scope.confirm_delete().then(() => {
        aq.each(objects, obj => {
          if (obj.record_type != "Module" || obj.deletable($scope.plan)) {
            $scope.delete_object(obj);
          } else {
            alert(
              "Module in multiple selection cannot be deleted because it contains active operations."
            );
          }
        });
        $scope.$apply();
      });

      $scope.select(null);
    }
  };

  $scope.add_module_input = function() {
    $scope.plan.current_module.add_input();
    $scope.plan.base_module.associate_fvs();
  };

  $scope.add_module_output = function() {
    $scope.plan.current_module.add_output();
    $scope.plan.base_module.associate_fvs();
  };

  $scope.keyDown = function(evt) {
    switch (evt.key) {
      case "Backspace":
      case "Delete":
        if ($scope.current_draggable) {
          if (
            $scope.current_draggable.record_type == "Module" ||
            $scope.current_draggable.record_type == "ModuleIO" ||
            $scope.current_draggable.status == "planning" ||
            $scope.current_draggable.record_type == "TextBox"
          ) {
            $scope.delete();
          }
        }
        if ($scope.current_wire) {
          $scope.delete();
        }
        if ($scope.multiple_objects_selected()) {
          $scope.delete();
        }
        break;

      case "Escape":
        $scope.select(null);
        all_draggable(op => (op.multiselect = false));
        break;

      case "A":
      case "a":
        if (evt.ctrlKey || evt.metaKey) {
          $scope.select_all();
          evt.preventDefault();
        }
        break;

      case "R":
      case "r":
        if (evt.ctrlKey || evt.metaKey) {
          $scope.reload();
          evt.preventDefault();
        }
        break;

      case "M":
      case "m":
        if (evt.ctrlKey || evt.metaKey) {
          $scope.plan.create_module($scope.current_op);
          evt.preventDefault();
        }
        break;

      // case "N":
      // case "n":
      //   if ( evt.ctrlKey || evt.metaKey ) {
      //     $scope.new();
      //     evt.preventDefault();
      //   }
      //   break;

      case "O":
      case "o":
        if (evt.ctrlKey || evt.metaKey) {
          $scope.add_module_output();
          evt.preventDefault();
        }
        break;

      case "I":
      case "i":
        if (evt.ctrlKey || evt.metaKey) {
          $scope.add_module_input();
          evt.preventDefault();
        }
        break;

      case "S":
      case "s":
        if (evt.ctrlKey || evt.metaKey) {
          $scope.save($scope.plan);
          evt.preventDefault();
        }
        break;

      default:
    }
  };
}
