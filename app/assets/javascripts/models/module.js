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
    console.log(['new wire', wire]);
    return wire;
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
    return result;
  }

  input_pin_x(io) {
    return this.x + this.width/2 - 
           (this.index_of_input(io) - this.input.length/2.0 + 0.5) * AQ.snap;
  }

  input_pin_y(io) {
    return this.y + this.height;
  }  

  output_pin_x(io) {
    return this.x + this.width/2 - 
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

}
