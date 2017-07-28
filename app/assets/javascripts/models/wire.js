AQ.Wire.make = function(specs) {

  var wire = AQ.Wire.record(specs);

  if ( wire.from ) {
    wire.from.num_wires++;
  }
  if ( wire.to ) {
    wire.to.num_wires++;
  }

  return wire;

}

AQ.Wire.record_methods.disconnect = function() {

  var wire = this;

  if ( wire.from ) {
    wire.from.num_wires--;
    delete wire.from;
    delete wire.from_op;
  }
  if ( wire.to ) {
    wire.to.num_wires--;
    delete wire.to;
    delete wire.to_op;
  }
  
  return wire;  

}
