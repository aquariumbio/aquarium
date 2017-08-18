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

    console.log(["Module::from_object", plan])

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
    console.log("next_id: " + this.constructor.next_module_id)
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
    this.wires.push(new ModuleWire().build({
      type: "mod2op",
      from_module: this,
      from: from,
      to_op: to_op,
      to: to
    }));
  }

  connect_from_op(to, from, from_op) {  
    this.wires.push(new ModuleWire().build({
      type: "op2mod",
      to_module: this,
      to: to,
      from_op: from_op,
      from: from
    }));
  }

  num_inputs() {
    return this.inputs.length;
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

  constructor() {
    this.snap = 16;
  }

  build(object) {
    for ( var p in object ) {
      this[p] = object[p];
    }
    return this;    
  }

  from_object(w,module,plan) {

    console.log(["ModuleWire::from_object", plan])

    for ( var p in w ) {
      this[p] = w[p];
    }

    if ( this.from_module ) this.from_module = module;
    if ( this.to_module )  this.to_module = module;

    if ( this.from_op ) this.from_op = plan.find_by_id(this.from_op.id);
    if ( this.to_op )   this.to_op = plan.find_by_id(this.to_op.id);

    if ( this.from && this.from.record_type == "FieldValue" ) this.from = plan.find_by_id(this.from.id);
    if ( this.to && this.to.record_type == "FieldValue" )   this.to   = plan.find_by_id(this.to.id); 

    if ( this.from && this.from.record_type == "ModuleIO" ) this.from = aq.find(module.input, i => i.id == this.from.id );
    if ( this.to && this.to.record_type == "ModuleIO" )   this.to   = aq.find(module.output, i => i.id == this.to.id );

    console.log(this)

    return this;

  }

  consistent() {
    return true;
  }

  serialize() {

    var wire = { type: this.type };

    if ( this.from_module ) wire.from_module = { id: this.from_module.id };
    if ( this.to_module )   wire.to_module   = { id: this.to_module.id };

    if ( this.from_op ) wire.from_op = { rid: this.from_op.rid };
    if ( this.to_op )   wire.to_op   = { rid: this.to_op.rid };

    if ( this.from.record_type == "FieldValue" ) wire.from = { record_type: "FieldValue", rid: this.from.rid }
    if ( this.to.record_type == "FieldValue" )   wire.to =   { record_type: "FieldValue", rid: this.to.rid }

    if ( this.from.record_type == "ModuleIO" ) wire.from = { record_type: "ModuleIO", id: this.from.id }
    if ( this.to.record_type == "ModuleIO" )   wire.to =   { record_type: "ModuleIO",   id: this.to.id }

    return wire;

  }

  get x0() {
    switch ( this.type  ) {
      case "mod2op":     
        return this.from.x + this.from.width/2;
      case "op2mod":
        return this.from_op.x + this.from_op.width/2 + (this.from.index - this.from_op.num_outputs/2.0 + 0.5)*this.snap;
    }
  }

  get y0() {
    switch ( this.type  ) {
      case "mod2op":     
        return this.from.y;
      case "op2mod":
        return this.from_op.y;
    }    
  }

  get x1() {
    switch ( this.type  ) {
      case "mod2op": 
        return this.to_op.x + this.to_op.width/2 + (this.to.index - this.to_op.num_inputs/2.0 + 0.5)*this.snap
      case "op2mod":
        return this.to.x + this.to.width/2;    
    }

  }

  get y1() {
    switch ( this.type  ) {
      case "mod2op":     
        return this.to_op.y + this.to_op.height;
      case "op2mod":
        return this.to.y + this.to.height;      
    }
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