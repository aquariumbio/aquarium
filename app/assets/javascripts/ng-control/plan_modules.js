AQ.Plan.record_methods.close_current_module = function() {
  var plan = this;
  plan.current_module = plan.find_module(plan.current_module.parent_id);
}    

AQ.Plan.record_methods.open_module = function(module) {
  this.current_module = module;
}

AQ.Plan.record_getters.current_module = function() {

  plan = this;
  delete plan.current_module;
  plan.current_module = plan.create_base_module();
  return plan.current_module;

}

AQ.Plan.record_methods.visible = function(obj) {

  var plan = this;

  switch ( obj.model.model ) {

    case "Operation":
    case "Module":
      if ( !obj.parent_id ) {
        obj.parent_id = 0;
      }
      return obj.parent_id == plan.current_module.id;

    case "Wire":
      if ( !obj.from_op.parent_id ) {
        obj.from_op.parent_id = 0;
      }
      if ( !obj.to_op.parent_id ) {
        obj.to_op.parent_id = 0;
      }      
      return obj.from_op.parent_id == plan.current_module.id &&
             obj.to_op.parent_id == plan.current_module.id;

  }

}

AQ.Plan.record_methods.create_base_module = function() {
  var plan = this;
  Module.next_module_id = 0;
  plan.base_module = new Module().for_parent(null);
  plan.current_module = plan.base_module;
  return plan.base_module;
}

AQ.Plan.record_methods.create_module = function(selected_op) {

  var plan = this,
      module,
      current = plan.current_module; // have to call this first

  module = new Module().for_parent(plan.current_module);

  aq.each(aq.where(plan.operations, op => op.multiselect), op => {
    op.parent_id = module.id;
  });   

  current.children.push(module);

  return module;

}

AQ.Plan.record_getters.modules = function() {

  var plan = this;
  
  if ( plan.base_module ) {
    plan.module_list = [ plan.base_module ];
    plan.make_module_list(plan.base_module);
  } else {
    plan.module_list = [];
  }

  return plan.module_list;

}

AQ.Plan.record_methods.make_module_list = function(m) {

  var plan = this;

  aq.each(m.children, c => {
    plan.module_list.push(c);
    plan.make_module_list(c)
  })

}

AQ.Plan.record_methods.find_module = function(id) {

  var plan = this,
      m;

  return aq.find(plan.modules, mod => mod.id == id);

}

AQ.Plan.record_methods.path_to_current_module = function() {

  var plan = this, 
      path = [], 
      mod = plan.current_module;

  if ( mod ) {

    while ( mod.id != 0 ) {
      path.unshift(mod.name);
      mod = plan.find_module(mod.parent_id)
    }

  } else {
    path = [];
  }

  return path;

}

