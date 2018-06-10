
class ModuleWire {

  constructor() {
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
      this.from = this.from_module.find_io_by_id(this.from.id);
    }

    if ( this.to && this.to.record_type == "ModuleIO" ) {
      this.to = this.to_module.find_io_by_id(this.to.id);
    }

    return this;

  }

  get record_type() {
    return "ModuleWire";
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
    if ( this.from_module ) {
      var to_object = this.to_op ? this.to_op : this.to_module;
      if ( this.from_module.parent_id == to_object.id ) {
        return this.from_module.output_pin_x(this.from);
      } else if ( this.from_module.parent_id != to_object.parent_id ) {  
        return this.from.output_pin_x();
      } else {
        return this.from_module.output_pin_x(this.from);
      }
    } else {
      return this.from_op.output_pin_x(this.from);
    }
  }

  get y0() {
    var to_object = this.to_op ? this.to_op : this.to_module;    
    if ( this.from_module ) {
      if ( this.from_module.parent_id == to_object.id ) {
        return this.from_module.output_pin_y();
      } else if ( this.from_module.parent_id != to_object.parent_id ) {    
        return this.from.output_pin_y(); 
      } else {
        return this.from_module.output_pin_y();
      }
    } else {
      return this.from_op.output_pin_y();
    }  
  }

  get x1() {
    var from_object = this.from_op ? this.from_op : this.from_module;
    if ( this.to_module ) {
      if ( this.to_module.parent_id == from_object.id ) {
        return this.to_module.input_pin_x(this.to); 
      } else if ( from_object.parent_id != this.to_module.parent_id ) {
        return this.to.input_pin_x(); 
      } else {
        return this.to_module.input_pin_x(this.to); 
      }
    } else {
      return this.to_op.input_pin_x(this.to); 
    }
  }

  get y1() {
    var from_object = this.from_op ? this.from_op : this.from_module;    
    if ( this.to_module ) {
      if ( this.to_module.parent_id == from_object.id ) {
        return this.to_module.input_pin_y(this.to);
      } else if ( from_object.parent_id != this.to_module.parent_id ) {      
        return this.to.input_pin_y(); 
      } else {
        return this.to_module.input_pin_y(this.to);
      }
    } else {
      return this.to_op.input_pin_y(); 
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
    return this.y0 - AQ.snap;
  };       

  get yint1() { 
    return this.y1 + AQ.snap;
  };           

  get path() {

    if ( this.y0 >= this.y1 + 2 * AQ.snap ) {

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
         " L " + (this.x1 + 0.25*AQ.snap) + " " + (this.y1 + 0.75*AQ.snap) + 
         " L " + (this.x1 - 0.25*AQ.snap) + " " + (this.y1 + 0.75*AQ.snap) + " Z";
  }

  get to_s() {

    var wire = this,
        str = "Wire. ";

    if ( wire.from_module ) {
      str += "Module " + wire.from_module.id + " (io " + wire.from.rid + ")";
    } else {
      str += "Operation " + wire.from_op.rid + " (fv " + wire.from.rid + ")";
    }

    str += " --> "

    if ( wire.to_module ) {
      str += "Module " + wire.to_module.id + " (io " + wire.to.rid + ")";
    } else {
      str += "Operation " + wire.to_op.rid + " (fv " + wire.to.rid + ")";
    }

    return str;

  }

  get from_obj() {
    return this.from_module ? this.from_module : this.from_op;    
  }

  get to_obj() {
    return this.to_module ? this.to_module : this.to_op;    
  }  

}

