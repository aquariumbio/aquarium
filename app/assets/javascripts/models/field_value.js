
AQ.FieldValue.getter(AQ.Item,"item","child_item_id");

AQ.FieldValue.record_getters.is_sample = function() {
  return this.field_type.ftype == 'sample';
}

AQ.FieldValue.record_getters.is_param = function() {
  return this.field_type.ftype != 'sample';
}

AQ.FieldValue.record_getters.type = function() {
  return this.field_type.ftype;
}

AQ.FieldValue.record_getters.num_wires = function() {
  delete this.num_wires;
  this.num_wires = 0;
  return 0;
}

AQ.FieldValue.record_getters.wired = function() {
  return this.num_wires > 0;
}

AQ.FieldValue.record_getters.predecessors = function() {

  var fv = this;
  var preds = [];

  aq.each(AQ.operation_types,function(ot) {
    aq.each(ot.field_types,function(ft) {
      if ( ft.role == 'output' && ft.can_produce(fv) ) {
        preds.push({operation_type: ot, output: ft});
      } 
    });
  });

  delete fv.predecessors;
  fv.predecessors = preds;
  return preds;

}

AQ.FieldValue.record_getters.successors = function() {

  var fv = this;
  var sucs = [];

  aq.each(AQ.operation_types,function(ot) {
    aq.each(ot.field_types,function(ft) {
      if ( ft.role == 'input' && ft.can_consume(fv) ) {
        sucs.push({operation_type: ot, input: ft});
      } 
    });
  });

  delete fv.successors;
  fv.successors = sucs;
  return sucs;

}

AQ.FieldValue.record_getters.is_wired_to = function() {
  var fv = this;
  return function(wire) { return wire.to == fv; }
}

AQ.FieldValue.record_methods.reload = function() {

  var fv = this;
  AQ.FieldValue.find(fv.id).then(updated_fv => {
    fv.child_item_id = updated_fv.child_item_id;
    fv.row = updated_fv.row;
    fv.column = updated_fv.column;
    fv.recompute_getter("item");
  });

}

AQ.FieldValue.record_methods.route_compatible = function(other_fv) {
  var fv = this;
  return ( !other_fv.array && !fv.array && other_fv.routing == fv.routing ) ||
         (  other_fv.array &&  fv.array && other_fv.sample_identifier == fv.sample_identifier );
}

AQ.FieldValue.record_methods.clear_item = function() {

  var fv = this;

  delete fv.child_item;
  delete fv.child_item_id;
  delete fv.row;
  delete fv.column;
  return fv;

}

AQ.FieldValue.record_methods.clear = function() {
  console.log("WARNING: Called FieldValue:clear(), which doesn't do anything anymore")
  return this;
}

AQ.FieldValue.record_methods.choose_item = function(items) {

  let fv = this;

  // Only choose an item if one is not already chosen 
  if ( items.length > 0 && ( !fv.child_item_id || !aq.member(aq.collect(items, i => i.id), fv.child_item_id ) ) ) {
    delete fv.items;
    fv.items = items;    
    if ( fv.role == 'input' && fv.num_wires == 0 ) {
      if ( !items[0].collection ) {
        fv.child_item_id = items[0].id;
      } else if ( fv.row == null || fv.row == undefined || !fv.column == null || fv.column == undefined ) {
        fv.child_item_id = items[0].collection.id;
        items[0].collection.assign_first(fv);
      }
    }
  }  

  return fv.child_item_id;

}

AQ.FieldValue.record_methods.find_items = function(sid) {

  var fv = this,
      promise = Promise.resolve(),
      sample_id = typeof sid == 'string' ? AQ.id_from(sid) : sid;

  if ( !sample_id ) {
    sample_id = fv.child_sample_id;
  }

  if ( fv.field_type.ftype == 'sample' && sample_id ) {
    promise = promise
      .then( () => AQ.items_for(sample_id,fv.aft.object_type_id) )
      .then( items => fv.choose_item(items) )
      .then( () => AQ.update() )
  } else {
    fv.items = [];
  }

  return promise;

}

AQ.FieldValue.record_methods.assign_item = function(item) {
  let fv = this;
  fv.child_item_id = item.id;
  fv.child_item = item;
}

AQ.FieldValue.record_getters.items = function() {

  var fv = this;

  if ( fv.child_sample_id ) {

    delete fv.items;
    fv.find_items(""+fv.child_sample_id);

  } else {

    delete fv.items;
    fv.items = [];

  }

}

AQ.FieldValue.record_getters.sample = function() {

  var fv = this;
  delete fv.sample;

  if ( fv.sid && typeof fv.sid == 'string' ) {
    AQ.Sample.find(fv.sid.split(": ")[0]).then(s => {
      fv.sample = s;
    });
  } else if ( fv.child_sample_id ) {
    AQ.Sample.find(fv.child_sample_id).then(s => {
      fv.sample = s;
    });
  } else {
    console.log("Warning: fv.sid = '" + fv.sid + "'")
  }
  return undefined;

}

AQ.FieldValue.record_methods.preferred_predecessor = function(operation) {
  var fv = this;
  var preds = aq.where(fv.predecessors, p => {
    return p.operation_type.id == fv.field_type.preferred_operation_type_id;
  });
  if ( preds.length == 1 ) {
    return preds[0];
  } else {
    return null;
  }
}

AQ.FieldValue.record_methods.samp_id = function(operation) {

  var fv = this;

  if ( fv.field_type.array ) {
    return fv.sample_identifier;
  } else {
    return operation.routing[fv.routing];
  } 
}

AQ.FieldValue.record_methods.valid = function() {

  var fv = this, 
      v = false;

  if ( fv.field_type.ftype != 'sample' ) {
    v = !! fv.value;
  } else if ( fv.aft && fv.aft.sample_type_id ) {
    v = !!fv.child_sample_id && ( fv.num_wires > 0 || fv.role == 'output' || !!fv.child_item_id );
  } else {
    v = fv.num_wires > 0 || fv.role == 'output' || !!fv.child_item_id;
  }

  if ( fv.role == 'input' && 
       fv.num_wires == 0 && 
       fv.field_type.part && 
       ( typeof fv.row != 'number' || typeof fv.column != 'number' ) ) {
    v = false;
  }

  return v;

} 

AQ.FieldValue.record_methods.empty = function() {
  var fv = this;
  return fv.child_sample_id;
} 

AQ.FieldValue.record_methods.assign = function(sample) {

  let field_value = this;

  if ( sample ) {

    field_value.child_sample_id = sample.id;
    field_value.sid = sample.identifier;

    if ( field_value.field_type && field_value.field_type.array ) {
      field_value.sample_identifier = sample.identifier;
    } 

  } else {

    field_value.child_sample_id = null;
    field_value.sid = null;
    field_value.sample_identifier = null;

  }

  return field_value;

}
