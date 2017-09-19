class Module {

  constructor() {
  }

  for_parent(parent) {

    this.name = "Untitled Module " + this.next_id;
    this.id = this.next_id;
    this.x = 160;
    this.y = 160;
    this.width = 160;
    this.height = 60;
    this.children = [];
    this.model = { model: "Module" }; // for compatability with AQ.Record
    this.input = []; 
    this.output = [];
    this.wires = [];
    this.parent_id = parent ? parent.id : -1;
    this.documentation = "No documentation yet for this module."

    this.inc_next_id();

    return this;

  }

  from_object(object,plan) {

    for ( var p in object ) {
      this[p] = object[p];
    }

    this.width = 160;
    this.height = 60;    

    if ( typeof this.x == 'string' ) {
      console.log("WARNING: module x coordinate is a string. Converting");
      this.x = parseFloat(this.x);
      console.log("got ", this.x)
    }

    if ( typeof this.y == 'string' ) {
      console.log("WARNING: module x coordinate is a string. Converting");
      this.y = parseFloat(this.y);
    }

    if ( !this.children ) this.children = [];
    if ( !this.input ) this.input = [];
    if ( !this.output ) this.output = [];
    if ( !this.wires ) this.wires = [];    

    this.input = aq.collect(this.input,       i => new ModuleIO().from_object(i) )
    this.output = aq.collect(this.output,     o => new ModuleIO().from_object(o) )
    this.children = aq.collect(this.children, c => new Module().from_object(c,plan) )
    this.wires = aq.collect(this.wires,       w => new ModuleWire().from_object(w,this,plan) )

    if ( !this.documentation ) {
      this.documentation = "No documentation yet for this module."
    }

    this.constructor.next_module_id++;

    return this;

  }

  get next_id() {
    if ( !this.constructor.next_module_id ) {
      // console.log("Resetting Module.next_id to zero")
      this.constructor.next_module_id = 0;
    }
    return this.constructor.next_module_id;
  }

  get record_type() {
    return "Module";
  }

  inc_next_id() {
    this.constructor.next_module_id++;
  }

  add_input(fv) { // why does this have an fv argument that it ignores?
    var m = new ModuleIO().build();
    m.x = this.next_input_pos;
    m.y = 320;
    this.input.push(m);
    return m;
  }

  add_output(fv) { // why does this have an fv argument that it ignores?
    var m = new ModuleIO().build();
    m.x = this.next_output_pos;
    m.y = 32;
    this.output.push(m);
    return m;
  }

  get next_input_pos() {
    if ( !this.constructor.input_pos) {
      this.constructor.input_pos = 48;
    } else {
      this.constructor.input_pos += 48;
    }
    return this.constructor.input_pos;
  }

  get next_output_pos() {
    if ( !this.constructor.output_pos) {
      this.constructor.output_pos = 48;
    } else {
      this.constructor.output_pos += 48;
    }
    return this.constructor.output_pos;
  }  

  connect(io1, object1, io2, object2) {
    var wire = new ModuleWire().build({
      from: io1,
      to: io2,
      from_op:     object1.record_type == 'Operation' ? object1 : null,
      to_op:       object2.record_type == 'Operation' ? object2 : null,
      from_module: object1.record_type == 'Module'    ? object1 : null,
      to_module:   object2.record_type == 'Module'    ? object2 : null 
    });
    this.wires.push(wire);  
    // console.log([this.name, this.wires])
    return wire;
  }

  num_inputs() {
    return this.inputs.length;
  }


  remove_child_operations(plan) {

    var module = this,
        ops = aq.where(plan.operations, op => op.parent_id == module.id);

    plan.wires = aq.where(plan.wires, w => {
      var remove = ops.includes(w.to_op) || ops.includes(w.from_op);
      if ( remove ) {
        w.disconnect();
      }              
      return !remove;
    });

    plan.operations = aq.where(plan.operations, op => op.parent_id != module.id);

    aq.each(module.children, c => c.remove_child_operations(plan));

  }

  remove(child,plan) {

    var module = this,
        old_wires = plan.get_implied_wires();

    child.remove_child_operations(plan);
    aq.remove(this.children, child);
    this.wires = aq.where(this.wires, w => w.from_module != child && w.to_module != child);

    plan.delete_obsolete_wires(old_wires);
    module.associate_fvs();
    plan.recount_fv_wires();

  }

  remove_io(io, plan) {

    var module = this,
        old_wires = plan.get_implied_wires();

    plan.base_module.remove_wires_connected_to(io);

    aq.remove(module.input, io);
    aq.remove(module.output, io);    

    plan.delete_obsolete_wires(old_wires);
    module.associate_fvs();
    plan.recount_fv_wires();    

  }

  remove_wires_connected_to(io) {

    var module = this;  
    var old_wires = plan.get_implied_wires();

    module.wires = aq.where(module.wires, w => w.from != io && w.to != io);
    aq.each(module.children, c => c.remove_wires_connected_to(io));

    plan.delete_obsolete_wires(old_wires);
    module.associate_fvs();
    plan.recount_fv_wires();    

  }

  remove_operation(op) {
    this.wires = aq.where(this.wires, w => w.from_op != op && w.to_op != op);
  }

  index_of_input(io) {
    return this.input.indexOf(io);
  }

  index_of_output(io) {
    return this.output.indexOf(io);
  }  

  find_by_id(mid) {
    var result;
    if ( this.id == mid ) {
      result = this;
    } else {
      result = aq.find(this.children, c => c.id == mid);
    }
    return result;
  }

  find_io_by_id(id) {

    var result = aq.find(this.input, i => i.id == id);
    if ( result ) return result;

    result = aq.find(this.output, o => o.id == id);
    if ( result ) return result;

    for ( var c in this.children ) {
      result = this.children[c].find_io_by_id(id);
      if ( result ) return result;
    }

    return null;

  }

  input_pin_x(io) {
    return this.x + this.width/2 +
           (this.index_of_input(io) - this.input.length/2.0 + 0.5) * AQ.snap;
  }

  input_pin_y(io) {
    return this.y + this.height;
  }  

  output_pin_x(io) {
    return this.x + this.width/2 +
           (this.index_of_output(io) - this.output.length/2.0 + 0.5) * AQ.snap;
  }

  output_pin_y(io) {
    return this.y;
  }  

  role(io) {
    if ( this.input.includes(io) ) {
      return 'input';
    } else if ( this.output.includes(io) ) {
      return 'output';
    } else {
      return null;
    }
  }

  get all_wires() {

    var wires = this.wires;

    aq.each(this.children, c => {
      wires = wires.concat(c.all_wires)
    });

    return wires;
  }

  num_wires_into(io) {

    var n = aq.where(this.wires, w => w.to.rid == io.rid).length;

    aq.each(this.children, c => {
      n += c.num_wires_into(io);
    });

    return n;

  }

  remove_wire(wire) {
    aq.remove(this.wires,wire);
  }

  origin(io) {

    var result = null,
        module = this,
        wire = aq.find(this.all_wires, w => io.id == w.to.id);

    if ( wire ) {
      // console.log("A: origin: io " + io.id + " is the end of wire " + wire.from.rid + " ---> " + wire.to.rid)
      if ( wire.from.record_type == "FieldValue" ) {
        result = { io: wire.from, op: wire.from_op };
      } else {
        result = module.origin(wire.from);
      }
    } else {
      result = { io: {}, op: {} }
    }

    return result;

  }

  destinations_aux(io,op=null) {

    var results = [],
        module = this,
        wires = aq.where(this.all_wires, w => io.rid == w.from.rid);

    if ( wires.length > 0 ) {

      // console.log(["destinations", io, module, wires])      

      for ( w in wires ) {
        if ( !wires[w].marked ) { // not sure why this is needed, but it prevents an inf loop
                                  // when modularizig a selection in an unsaved plan.
          wires[w].marked = true;
          results = results.concat(module.destinations_aux(wires[w].to, wires[w].to_op));
        }
      }
   
    } else {

      results = [{io: io, op: op}]

    }

    return results;

  } 

  destinations(io,op) {
    aq.each(this.all_wires, w => delete w.marked);
    return this.destinations_aux(io,op);
  }

  get io() {
    return this.input.concat(this.output);
  }

  get all_io() {
    var io_list = this.io;
    for ( var c in this.children ) {
      io_list = io_list.concat(this.children[c].all_io);
    }
    return io_list;
  }  

  get all_input() {
    var io_list = this.input;
    for ( var c in this.children ) {
      io_list = io_list.concat(this.children[c].all_input);
    }
    return io_list;
  }

  get all_output() {
    var io_list = this.output;
    for ( var c in this.children ) {
      io_list = io_list.concat(this.children[c].all_output);
    }
    return io_list;
  }

  clear_fvs() {
    aq.each(this.all_io, io => {
      io.origin_fv = null;
      io.destinations = [];
    });
  }

  associate_fvs() {

    var module = this, 
        dests,
        origin;

    aq.each(module.all_io, io => {

      dests = module.destinations(io);

      io.destinations = aq.where(dests, d => d.io.record_type == "FieldValue");

      // console.log("associate_fvs: " + io.rid + ". origin: " + (io.origin ? io.origin.io.rid : null) + 
      //           ", destinations: [" +  aq.collect(io.destinations, d => d.io.rid).join(", ") + "]");

    });

    aq.each(module.all_io, io => {

      origin = module.origin(io);

      if ( origin.io.record_type == "FieldValue" ) {
        io.origin = origin;
      } else {
        io.origin = null;
      }

      // console.log("associate_fvs: " + io.rid + ". origin: " + (io.origin ? io.origin.io.rid : null) + 
      //           ", destinations: [" +  aq.collect(io.destinations, d => d.io.rid).join(", ") + "]");

    });  

  }

  renumber() {

    var module = this,
        old_id = module.id;

    module.id = module.next_id;
    module.inc_next_id();        

    if ( !this.constructor.id_map ) this.constructor.id_map = []
    this.constructor.id_map[old_id] = module.id;

    aq.each(this.input.concat(this.output), io => {
      io.id = io.next_id;
      io.inc_next_id();
    });

    aq.each(module.children, child => {
      child.parent_id = module.id;
      child.renumber();
    })

  }

  merge(new_module) {

    var module = this;

    module.wires = module.wires.concat(new_module.wires);

    aq.each(new_module.children, new_child => {
      new_child.parent_id = module.id;
      module.children.push(new_child);
    });

  }

  compute_cost(plan) {

    var module = this;

    module.cost = 0;

    aq.each(module.children,child => {
      module.cost += child.compute_cost(plan);
    });

    aq.each(plan.operations, op => {
      if ( op.parent_id == module.id ) {
        module.cost += op.cost;
      }
    })

    return module.cost;

  }

  get rendered_docs() {

    var module = this;
    var md = window.markdownit();
    return AQ.sce.trustAsHtml(md.render(module.documentation));

  }  

}
