class ModuleIO {

  constructor() {
  }

  build() { 
    this.id = this.next_id;
    this.inc_next_id();
    this.x = 160; this.y = this.next_pos;
    this.width = 32; this.height = 32;
    this.model = { model: "ModuleIO" }; // for compatability with AQ.Record
    return this;
  }

  from_object(object) {
    for ( var p in object ) {
      this[p] = object[p];
    }
    // this.id = this.next_id;
    this.inc_next_id();
    this.width = 32; this.height = 32;
    return this;
  }

  get record_type() {
    return "ModuleIO";
  }

  get rid() {
    return this.id; // for compatability with AQ.Record
  }

  get next_id() {
    if ( !this.constructor.next_io_id ) {
      this.constructor.next_io_id = 0;
    }
    return this.constructor.next_io_id;
  }

  inc_next_id() {
    if ( !this.constructor.next_io_id ) {
      this.constructor.next_io_id = 0;
    }    
    this.constructor.next_io_id++;
  }  

  input_pin_x() {
    return this.x + this.width/2;
  }

  input_pin_y() {
    return this.y + this.height;;
  }  

  output_pin_x() {
    return this.x + this.width/2;
  }

  output_pin_y() {
    return this.y;
  }  

  get is_param() {
    var io = this;
    if ( io.destinations && io.destinations.length > 0 ) {
      return io.destinations[0].io.field_type.ftype != 'sample';
    } else {
      return false;
    }
  }

}