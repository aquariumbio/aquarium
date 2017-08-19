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
    this.full_wires = [];
    this.parent_id = parent ? parent.id : -1;

    this.inc_next_id();

    return this;

  }

  from_object(object,plan) {

    for ( var p in object ) {
      this[p] = object[p];
    }

    this.width = 160;
    this.height = 60;    

    if ( !this.children ) this.children = [];
    if ( !this.input ) this.input = [];
    if ( !this.output ) this.output = [];
    if ( !this.wires ) this.wires = [];    

    this.input = aq.collect(this.input,       i => new ModuleIO().from_object(i) )
    this.output = aq.collect(this.output,     o => new ModuleIO().from_object(o) )
    this.children = aq.collect(this.children, c => new Module().from_object(c,plan) )
    this.wires = aq.collect(this.wires,       w => new ModuleWire().from_object(w,this,plan) )

    this.constructor.next_module_id++;

    return this;

  }

  get next_id() {
    if ( !this.constructor.next_module_id ) {
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

  add_input(fv) {
    var m = new ModuleIO().build();
    m.x = this.next_input_pos;
    m.y = 320;
    this.input.push(m);
  }

  add_output(fv) {
    var m = new ModuleIO().build();
    m.x = this.next_output_pos;
    m.y = 32;
    this.output.push(m);
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

  connect_mod_to_op(from, from_module, to, to_op) {
    this.wires.push(new ModuleWire().build({
      type: "mod2op",
      from_module: from_module,
      from: from,
      to_op: to_op,
      to: to
    }));
  }

  connect_mod_from_op(to, to_module, from, from_op) {  
    this.wires.push(new ModuleWire().build({
      type: "op2mod",
      to_module: to_module,
      to: to,
      from_op: from_op,
      from: from
    }));
  }

  num_inputs() {
    return this.inputs.length;
  }

  remove_child_operations(plan) {
    var module = this;
    plan.operations = aq.where(plan.operations, op => op.parent_id != module.id);
    aq.each(module.children, c => c.remove_child_operations(plan));
  }

  remove(child,plan) {
    child.remove_child_operations(plan);
    aq.remove(this.children, child);
  }

  remove_io(io) {
    aq.remove(this.input, io);
    aq.remove(this.output, io);
    this.wires = aq.where(this.wires, w => w.from != io && w.to != io);
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
    console.log(this)
    console.log(result)
    return result;
  }

}
