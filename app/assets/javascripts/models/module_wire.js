
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

    for ( var p in w ) {
      this[p] = w[p];
    }

    if ( this.from_module ) this.from_module = module.find_by_id(this.from_module.id);
    if ( this.to_module )   this.to_module   = module.find_by_id(this.to_module.id);

    if ( this.from_op ) this.from_op = plan.find_by_id(this.from_op.id);
    if ( this.to_op )   this.to_op = plan.find_by_id(this.to_op.id);

    if ( this.from && this.from.record_type == "FieldValue" ) this.from = plan.find_by_id(this.from.id);
    if ( this.to && this.to.record_type == "FieldValue" )     this.to   = plan.find_by_id(this.to.id); 

    if ( this.from && this.from.record_type == "ModuleIO" ) {
      this.from = aq.find(this.from_module.input.concat(this.from_module.output), i => i.id == this.from.id );
    }

    if ( this.to && this.to.record_type == "ModuleIO" ) {
      this.to   = aq.find(this.to_module.input.concat(this.to_module.output), i => i.id == this.to.id );
    }

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
    if ( this.to.record_type == "FieldValue" )   wire.to   = { record_type: "FieldValue", rid: this.to.rid }

    if ( this.from.record_type == "ModuleIO" ) wire.from = { record_type: "ModuleIO", id: this.from.id }
    if ( this.to.record_type == "ModuleIO" )   wire.to   = { record_type: "ModuleIO", id: this.to.id }

    return wire;

  }

  get x0() {
    switch ( this.type  ) {
      case "mod2op":   
        if ( this.from_module.parent_id != this.to_op.parent_id ) {  
          return this.from.x + this.from.width/2;
        } else {
          return this.from_module.x + this.from_module.width/2 - 
                 (this.from_module.index_of_output(this.from) - this.from_module.output.length/2.0 + 0.5) * this.snap;
        }
      case "op2mod":
        return this.from_op.x + this.from_op.width/2 + (this.from.index - this.from_op.num_outputs/2.0 + 0.5)*this.snap;
    }
  }

  get y0() {
    switch ( this.type  ) {
      case "mod2op":  
        if ( this.from_module.parent_id != this.to_op.parent_id ) {    
          return this.from.y;
        } else {
          return this.from_module.y;
        }
      case "op2mod":
        return this.from_op.y;
    }    
  }

  get x1() {
    switch ( this.type  ) {
      case "mod2op": 
        return this.to_op.x + this.to_op.width/2 + (this.to.index - this.to_op.num_inputs/2.0 + 0.5)*this.snap;
      case "op2mod":
        if ( this.from_op.parent_id != this.to_module.parent_id ) {
          return this.to.x + this.to.width/2;      
        } else {
          return this.to_module.x + this.to_module.width/2 - 
                (this.to_module.index_of_input(this.to) - this.to_module.input.length/2.0 + 0.5) * this.snap;
        }
    }
  }

  get y1() {
    switch ( this.type  ) {
      case "mod2op":     
        return this.to_op.y + this.to_op.height;
      case "op2mod":
        if ( this.from_op.parent_id != this.to_module.parent_id ) {      
          return this.to.y + this.to.height;      
        } else {
          return this.to_module.y + this.to_module.height;
        }
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