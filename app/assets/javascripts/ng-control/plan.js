(function() {

  var w = angular.module('aquarium'); 

  w.controller('planCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', '$window',
                  function (  $scope,   $http,   $attrs,   $cookies,   $sce,   $window ) {

    PlanSetup($scope,$http,$attrs,$cookies,$sce,$window);
    PlanMouse($scope,$http,$attrs,$cookies,$sce,$window);
    PlanKeyboard($scope,$http,$attrs,$cookies,$sce,$window);
    PlanClasses($scope,$http,$attrs,$cookies,$sce,$window);
    PlanWire($scope,$http,$attrs,$cookies,$sce,$window);
   
    // Actions ////////////////////////////////////////////////////////////////////////////////////

    $scope.select = function(object) {

      $scope.state.launch = false;

      $scope.current_draggable = object && ( object.model.model == "Operation" ||
                                             object.model.model == "Module" ||
                                             object.model.model == "ModuleIO" ) ? object : null;

      $scope.current_op     = object && object.model.model == "Operation" ? object : null;

      $scope.current_io     = object && ( object.model.model == "FieldValue" ||
                                          object.model.model == "ModuleIO" ) ? object : null;

      $scope.current_fv     = object && object.model.model == "FieldValue" ? object : null;      

      $scope.current_wire   = object && object.model.model == "Wire"       ? object : null;

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
        routing: {}, form: { input: {}, output: {} },
        parent_id: $scope.plan.current_module.id
      });
      $scope.last_place += 4*$scope.snap;
      op.set_type(ot);
      $scope.current_op = op;
      $scope.plan.operations.push(op);
      $scope.set_current_io(op.field_values[0],true);
      if ( $scope.plan.name == "Untitled Plan" ) {
        $scope.plan.name = op.operation_type.name;
        $scope.state.message = "Changed name of untitled plan to " + op.operation_type.name;
      }
    }

    $scope.add_predecessor = function(fv,op,pred) {

      var newop = $scope.plan.add_wire_from(fv,op,pred);
      $scope.plan.wires[$scope.plan.wires.length-1].snap = $scope.snap;
      newop.x = op.x;
      newop.y = op.y + 4*$scope.snap;
      newop.width = 160;
      newop.height = 30;
      newop.parent_id = $scope.plan.current_module.id;

      $scope.select(newop);
      var inputs = aq.where(newop.field_values, fv => fv.role == 'input');
      if ( inputs.length > 0 ) {
        $scope.set_current_io(inputs[0]);
      }

    }

    $scope.add_successor = function(fv,op,suc) {

      var newop = $scope.plan.add_wire_to(fv,op,suc);
      $scope.plan.wires[$scope.plan.wires.length-1].snap = $scope.snap;
      newop.x = op.x;
      newop.y = op.y - 4*$scope.snap;
      newop.width = 160;
      newop.height = 30;
      newop.parent_id = $scope.plan.current_module.id;

      $scope.select(newop);
      var fvs = aq.where(newop.field_values, fv => fv.role == 'output');
      if ( fvs.length > 0 ) {
        $scope.set_current_io(fvs[0]);
      }

    }    

    $scope.set_current_io = function(io,focus) {
      $scope.current_io = io;
      if ( io.model.model == "FieldValue" ) {
        $scope.current_fv = io;
      }
      if ( focus ) { 
        setTimeout(function() { 
          var el = document.getElementById('fv-'+io.rid);
          if ( el ) { el.focus() }
        }, 30);
      }
    }

    $scope.note = function(msg) {
      console.log(msg);
    }

    $scope.save = function(plan) {

      plan.save().then(saved_plan => {
        $scope.plan = saved_plan;
        $scope.state.loading_plans = true;
        $scope.select(null);
        $scope.$apply();
        refresh_plan_list();
      });

    }

    $scope.create_template = function(p) {

      p.status = "template";
      $scope.save(p);
      $scope.templates.push(p);
      $scope.state.sidebar.templates = true;
      $scope.state.sidebar.your_templates = true;

    }

    $scope.create_system_template = function(p) {

      p.status = "system_template";
      $scope.save(p);
      $scope.system_templates.push(p);
      $scope.state.sidebar.templates = true;
      $scope.state.sidebar.system_templates = true;

    }    

    $scope.delete_plan = function(p) {

      if ( confirm("Are you sure you want to delete plan " + p.id + "?") ) {

        $scope.new();
        $scope.state.deleting_plan = p;
        p.destroy().then(() =>  refresh_plan_list());

      }

    }

    $scope.load = function(plan) {
      AQ.Plan.load(plan.id).then(p => {
        $scope.plan = p;
        $scope.$apply();
      })
    }

    $scope.paste_plan = function(plan) {
      AQ.Plan.load(plan.id).then(p => {
        $scope.plan.paste_plan(p);
        $scope.$apply();
      })
    }    

    $scope.new = function() {
      $scope.plan = AQ.Plan.record({operations: [], wires: [], status: "planning", name: "Untitled Plan"});
      $scope.select(null)
    }    

    $scope.copy_plan = function(plan) {
      plan.replan().then(newplan => {
        $scope.plans.push(newplan);
        $scope.load(newplan)
      })
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

      $scope.select(null)
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

 
    $scope.openMenu = function($mdMenu, ev) {
      originatorEv = ev;
      $mdMenu.open(ev);
    };    

     // Inventory ////////////////////////////////////////////////////////////////////////////////////

    $scope.select_item = function(fv, item) {

      if ( fv.child_item_id != item.id && item.assign_first ) {
        item.assign_first(fv);
      }

      fv.child_item_id = item.id;
      fv.child_item = item;

    }

    $scope.select_row_column = function(fv,sid,collection,r,c) {      
      if ( fv.child_sample_id == sid ) {
        fv.child_item_id = collection.id;
        fv.child_item = collection;
        fv.row = r;
        fv.column = c;
      }
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

  w.directive('ngRightClick', function($parse) {
      return function(scope, element, attrs) {
          var fn = $parse(attrs.ngRightClick);
          element.bind('contextmenu', function(event) {
              scope.$apply(function() {
                  event.preventDefault();
                  fn(scope, {$event:event});
              });
          });
      };
  });

  w.directive('plannerCursor', function() {

    return {

      restrict: 'AE',
      scope: { x: '=', y: '=' },
      replace: true,
      template: $('#planner-cursor-template').html()

    }

  });

})();                    
