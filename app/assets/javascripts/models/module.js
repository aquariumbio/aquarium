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

  from_object(object) {

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
    this.children = aq.collect(this.children, c => new Module().from_object(c) )
    this.full_wires = [];    

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
    this.input.push(new ModuleIO().build());
  }

  add_output(fv) {
    this.output.push(new ModuleIO().build());
  }

  connect_to_op(from, to, to_op) {
    this.wires.push(new ModuleWire({
      from_module: this,
      from: from,
      to_op: to_op,
      to: to
    }));
  }

}

class ModuleIO {

  constructor() {
  }

  build() { 
    this.id = this.next_id;
    this.inc_next_id();
    this.x = 160; this.y = 160;
    this.width = 32; this.height = 32;
    this.model = { model: "ModuleIO" }; // for compatability with AQ.Record
    return this;
  }

  from_object(object) {
    for ( var p in object ) {
      this[p] = object[p];
    }
    this.id = this.next_id;
    this.inc_next_id();
    this.width = 32; this.height = 32;
    return this;
  }

  get record_type() {
    return "ModuleIO";
  }

  get next_id() {
    if ( !this.constructor.next_io_id ) {
      this.constructor.next_io_id = 0;
    }
    return this.constructor.next_io_id;
  }

  inc_next_id() {
    this.constructor.next_io_id++;
  }  

}

class ModuleWire {

  constructor(object) {
    for ( var p in object ) {
      this[p] = object[p];
    }
    this.snap = 16;
    return this;    
  }

  consistent() {
    return true;
  }

  get x0() {
    return this.from.x + this.from.width/2;
  }

  get y0() {
    return this.from.y;
  }

  get x1() {
    return this.to_op.x + this.to_op.width/2 + (this.to.index - this.to_op.num_inputs/2.0 + 0.5)*this.snap
  }

  get y1() {
    return this.to_op.y + this.to_op.height;
  }  

  get ymid() { 
    if ( !this.ymid_frac ) { this.ymid_frac = 0.5; }
    return this.ymid_frac*(this.y0 + this.y1);
  }  

  get xmid() { 
    if ( !this.xmid_frac ) { this.xmid_frac = 0.5; }
    return this.xmid_frac*(this.x0 + this.x1);
  }

  get yint0() { 
    return this.y0 - this.snap;
  };       

  get yint1() { 
    return this.y1 + this.snap;
  };           

  get path() {

    if ( this.y0 >= this.y1 + 2 * this.snap ) {

      return ""   + this.x0 + "," + this.y0 + 
             " "  + this.x0 + "," + this.ymid + 
             " "  + this.x1 + "," + this.ymid +    
             " "  + this.x1 + "," + this.y1;

    } else {

      return ""   + this.x0   + "," + this.y0 + 
             " "  + this.x0   + " " + this.yint0 +           
             " "  + this.xmid + "," + this.yint0 + 
             " "  + this.xmid + "," + this.yint1 +   
             " "  + this.x1   + "," + this.yint1 +                 
             " "  + this.x1   + "," + this.y1;          

     }

  }  

  get arrowhead() {
      return "M "  + this.x1 + " " + (this.y1 + 5) + 
         " L " + (this.x1 + 0.25*this.snap) + " " + (this.y1 + 0.75*this.snap) + 
         " L " + (this.x1 - 0.25*this.snap) + " " + (this.y1 + 0.75*this.snap) + " Z";
  }

}