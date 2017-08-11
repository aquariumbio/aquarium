function PlanModules($scope,$http,$attrs,$cookies,$sce,$window) {


}

AQ.Plan.add_module = function(parent, name, x, y) {

  var plan = this;

  if ( !plan.next_module_id ) {
    plan.next_module_id = 0;
  }

  aq.each(aq.where(plan.operations, op => op.multi_select), op => {
    op.parent_module_id = plan.next_module_id;
  }); 

  parent.children.push({
    id: plan.next_module_id,
    name: name, 
    x: x, 
    y: y
  });

  plan.next_module_id++;

}