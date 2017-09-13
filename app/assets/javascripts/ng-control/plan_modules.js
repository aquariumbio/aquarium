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

  switch ( obj.record_type) {

    case "Operation":
    case "Module":
      if ( !obj.parent_id ) {
        obj.parent_id = 0;
      }
      return obj.id != 0 && obj.parent_id == plan.current_module.id;

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

AQ.Plan.record_methods.create_module = function() {

  var plan = this,
      module,
      selected_ops = aq.where(plan.operations, op => op.multiselect),
      current = plan.current_module, // have to call this first (getter with a side effect of 
                                     // making the current module if it doesn't exist)
      selected_modules = aq.where(current.children, child => child.multiselect),  
      wires_to_be_moved = [];                                   
      x = 0, y = 0, n = 0;

  aq.each(plan.base_module.all_wires, w => console.log("   " + w.to_s));

  module = new Module().for_parent(plan.current_module);

  current.children.push(module);

  aq.each(selected_ops, op => {
    op.parent_id = module.id;
    x += op.x;
    y += op.y;
    n++;
  });

  aq.each(selected_modules, selected_module => {

    // collect wires that connect things to selected module to newly created module
    aq.each(current.wires, wire => {
      if ( wire.from_module == selected_module || wire.to_module == selected_module ) {
        if ( !plan.wire_in_module(current,wire) ) {
          wires_to_be_moved.push(wire);
        }
      }
    })

    selected_module.parent_id = module.id;
    aq.remove(current.children, selected_module);
    module.children.push(selected_module);

    x += selected_module.x;
    y += selected_module.y; 
    n++;

  });  

  if ( n > 0 ) {

    module.x = x/n;
    module.y = y/n;
    console.log("new module pos", x, y, n, module.x, module.y)
    plan.add_module_wires_from_real(module);
    plan.add_module_wires_from_module_wires(module);

    aq.each(wires_to_be_moved, wire => { 
      console.log("  Moving " + wire.to_s)
      aq.remove(current.wires, wire)
      module.wires.push(wire);
    });

    plan.delete_old_module_wires(module);

  }

  console.log("----------")
  aq.each(plan.base_module.all_wires, w => console.log("   " + w.to_s));

  plan.base_module.associate_fvs();

  return module;

}

AQ.Plan.record_methods.wire_in_module = function(current, wire) {

  var p1 = wire.from_module ? wire.from_module.parent_id : wire.from_op.parent_id,
      p2 = wire.to_module ? wire.to_module.parent_id : wire.to_op.parent_id;

      console.log(current.id, p1,p2)

  return p1 == current.id && p2 == current.id;

}

AQ.Plan.record_methods.add_module_wires_from_real = function(new_module) {

  var plan = this,
      current = plan.current_module;

  aq.each(plan.wires, w => {

    if ( w.from_op.parent_id == current.id && w.to_op.parent_id == new_module.id ) {
      var new_io = new_module.add_input();
      plan.connect(w.from, w.from_op, new_io, new_module);
      plan.current_module = new_module;
      plan.connect(new_io, new_module, w.to, w.to_op);      
      plan.current_module = current;
    }

  });

  aq.each(plan.wires, w => {

    if ( w.from_op.parent_id == new_module.id && w.to_op.parent_id == current.id ) {
      var new_io = new_module.add_output();
      plan.current_module = new_module;      
      plan.connect(w.from, w.from_op, new_io, new_module);
      plan.current_module = current;   
      plan.connect(new_io, new_module, w.to, w.to_op);      
    }      

  });

}

AQ.Plan.record_methods.add_module_wires_from_module_wires = function(new_module) {

  var plan = this,
      current = plan.current_module;

  aq.each_in_reverse(current.wires, w => {

    if ( ( w.from_obj.parent_id == current.id && w.to_obj.parent_id == new_module.id ) ||
         ( w.from_obj.parent_id == current.parent_id && w.to_obj.parent_id == new_module.id ) ) {

      console.log("Building new wires for " + w.to_s);

      var new_io = new_module.add_input();

      plan.connect(w.from, w.from_obj, new_io, new_module);
      plan.current_module = new_module;
      plan.connect(new_io, new_module, w.to, w.to_obj);      
      plan.current_module = current;      

    }

  });

  aq.each(current.wires, w => {

    if ( ( w.from_obj.parent_id == new_module.id && w.to_obj.parent_id == current.id ) ||
         ( w.from_obj.parent_id == new_module.id && w.to_obj.parent_id == current.parent_id ) ) {

      console.log("Building new wires for " + w.to_s);

      var new_io = new_module.add_output();

      plan.current_module = new_module;      
      plan.connect(w.from, w.from_obj, new_io, new_module);
      plan.current_module = current;   
      plan.connect(new_io, new_module, w.to, w.to_obj);   

    }          

  });

}

//
// For deleting wires, its always from the current module and its any module wire that ends
// in the selection. Should delete wires after adding the new ones,
// because you need the old ones to figure out what the new ones are.
// 

AQ.Plan.record_methods.delete_old_module_wires = function(new_module) {

  var plan = this;
  aq.each(plan.current_module.wires, w => {
    if ( plan.uses_module(w, new_module) ) {
      console.log("  Removing " + w.to_s)
    }
  });
  plan.current_module.wires = aq.where(plan.current_module.wires, w => !plan.uses_module(w, new_module));

}

AQ.Plan.record_methods.uses_module = function(w,new_module) {

  return ( w.from_module && w.from_module.parent_id == new_module.id ) ||
         ( w.from_op     && w.from_op.parent_id     == new_module.id ) ||
         ( w.to_module   && w.to_module.parent_id   == new_module.id ) ||
         ( w.to_op       && w.to_op.parent_id       == new_module.id );

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

