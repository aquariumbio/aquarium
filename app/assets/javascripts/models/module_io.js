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