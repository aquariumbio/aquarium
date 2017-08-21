(function() {

  var w = angular.module('aquarium'); 

  w.controller('planCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce', '$window', '$mdDialog',
                  function (  $scope,   $http,   $attrs,   $cookies,   $sce,   $window,   $mdDialog ) {

    PlanSetup($scope,$http,$attrs,$cookies,$sce,$window);
    PlanMouse($scope,$http,$attrs,$cookies,$sce,$window);
    PlanClasses($scope,$http,$attrs,$cookies,$sce,$window);
    PlanWire($scope,$http,$attrs,$cookies,$sce,$window);
   
    // Actions ////////////////////////////////////////////////////////////////////////////////////

    $scope.select = function(object) {

      $scope.state.launch = false;

      $scope.current_draggable = object && ( object.record_type == "Operation" ||
                                             object.record_type == "Module" ||
                                             object.record_type == "ModuleIO" ) ? object : null;

      $scope.current_op     = object && object.record_type == "Operation" ? object : null;

      $scope.current_io     = object && ( object.record_type == "FieldValue" ||
                                          object.record_type == "ModuleIO" ) ? object : null;

      $scope.current_fv     = object && object.record_type == "FieldValue" ? object : null;      

      $scope.current_wire   = object && ( object.record_type == "Wire" || 
                                          object.record_type == "ModuleWire" ) ? object : null;

      console.log([object,$scope.current_wire]);

    }

    function refresh_plan_list() {
      AQ.Plan.where({status: "planning", user_id: $scope.current_user.id}).then(plans => { 
        $scope.state.loading_plans = false;
        $scope.plans = plans;
      });
    }

    $scope.add_operation = function(ot) {
      var op = AQ.Operation.record({
        x: 100+3*AQ.snap + $scope.last_place, 
        y: 100+2*AQ.snap + $scope.last_place, 
        width: 160, 
        height: 30,
        routing: {}, form: { input: {}, output: {} },
        parent_id: $scope.plan.current_module.id
      });
      $scope.last_place += 4*AQ.snap;
      op.set_type(ot);
      $scope.plan.operations.push(op);
      if ( $scope.plan.name == "Untitled Plan" ) {
        $scope.plan.name = op.operation_type.name;
        $scope.state.message = "Changed name of untitled plan to " + op.operation_type.name;
      }
    }

    $scope.add_predecessor = function(fv,op,pred) {

      var newop = $scope.plan.add_wire_from(fv,op,pred);
      $scope.plan.wires[$scope.plan.wires.length-1].snap = AQ.snap;
      newop.x = op.x;
      newop.y = op.y + 4*AQ.snap;
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
      $scope.plan.wires[$scope.plan.wires.length-1].snap = AQ.snap;
      newop.x = op.x;
      newop.y = op.y - 4*AQ.snap;
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

    function open_templates() {
      $scope.state.sidebar.templates = true;        
      $scope.state.sidebar.your_templates = true;
      $scope.state.sidebar.system_templates = true;      
    }

    $scope.create_template = function(p) {

      p.status = "template";
      p.save().then(() => {
        $scope.templates.push(p);
        open_templates() 
        $scope.plan = AQ.Plan.record({operations: [], wires: [], status: "planning", name: "Untitled Plan"});
        $scope.select(null);  
        refresh_plan_list();
      })

    }

    $scope.create_system_template = function(p) {

      AQ.Plan.load(p.id).then(p => {
        p.status = "system_template";
        p.save().then(() => {
          aq.remove($scope.templates, p);  
          $scope.system_templates.push(p);
          open_templates() 
          $scope.plan = AQ.Plan.record({operations: [], wires: [], status: "planning", name: "Untitled Plan"});
          $scope.select(null);  
          $scope.$apply();    
        })
      })      

    }

    $scope.revert_template = function(plan) {

      AQ.Plan.load(plan.id).then(p => {
        p.status = "planning";
        p.save().then(p => {
          aq.remove($scope.templates, plan);  
          aq.remove($scope.system_templates, plan); 
          $scope.plan = p
          refresh_plan_list();
          $scope.select(null);  
          $scope.$apply();    
        })
      })      

    }    

    $scope.delete_plan = function(p) {

      var confirm = $mdDialog.confirm()
          .title('Delete Plan?')
          .textContent("Do you really want to delete the plan \"" + p.name + "\"?")
          .ariaLabel('Delete')
          .ok('Yes')
          .cancel('No')

      if ( p.id ) {

        $mdDialog.show(confirm).then( () => {

          $scope.plan = AQ.Plan.record({operations: [], wires: [], status: "planning", name: "Untitled Plan"});
          $scope.select(null)
          $scope.state.deleting_plan = p;
          p.destroy().then(() =>  refresh_plan_list());

        }, () => null );

      }

    }

    function save_first(msg) {

      return new Promise( function(resolve,reject) {

        if ( $scope.plan.operations.length > 0 ) {

          var dialog = $mdDialog.confirm()
              .clickOutsideToClose(true)
              .title('Save First?')
              .textContent(msg ? msg : "Save the current plan before loading \"" + plan.name + "\"?")
              .ariaLabel('Save First?')
              .ok('Yes')
              .cancel('No');

          $mdDialog.show(dialog).then( 
            () => $scope.plan.save().then(resolve),
            resolve
          )        

        } else {

          resolve();

        }

      })

    }

    function load_aux(plan) {
      AQ.Plan.load(plan.id).then(p => {
        $scope.plan = p;
        $scope.$apply();
      })      
    }

    $scope.load = function(plan) {
      save_first().then(() => load_aux(plan));
    }

    $scope.paste_plan = function(plan) {
      AQ.Plan.load(plan.id).then(p => {
        $scope.plan.paste_plan(p);
        $scope.$apply();
      })
    }    

    $scope.new = function() {
      save_first("Save current plan before creating new plan?").then( () => {
        $scope.plan = AQ.Plan.record({operations: [], wires: [], status: "planning", name: "Untitled Plan"});
        $scope.select(null);
        $scope.$apply();
      });
    }

    $scope.copy_plan = function(plan) {
      plan.replan().then(newplan => {
        $scope.plans.push(newplan);
        load_aux(newplan);
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

    $scope.delete_object = function(obj) {

      if ( obj.record_type == "Operation" ) {
        aq.remove($scope.plan.operations, obj);                               
        $scope.plan.wires = aq.where($scope.plan.wires, w => {
          var remove = w.to_op == obj || w.from_op == obj;
          if ( remove ) {
            w.disconnect();
          }              
          return !remove;
        });
        $scope.current_op = null;
      } else if ( obj.record_type == "Module" ) {
         var confirm = $mdDialog.confirm()
          .title('Delete Module?')
          .textContent("Do you really want to delete the module \"" + obj.name + "\" and all of its contents?")
          .ariaLabel('Delete')
          .ok('Yes')
          .cancel('No');
        $mdDialog.show(confirm).then( 
          () => $scope.plan.current_module.remove(obj,$scope.plan),
          () => null);

      } else if ( obj.record_type == "ModuleIO" ) {        
        $scope.plan.current_module.remove_io(obj);
      }

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

  w.directive('plannerAction', function() {

    return {

      restrict: 'AE',
      scope: { icon: '@', name: '@', tooltip: '@', isDisabled: "=" }, // note: using @ so that caller can say icon="x" instead of icon="'x'"
      replace: true,
      template: $('#planner-action-template').html()

    }

  });  
 

})();                    
