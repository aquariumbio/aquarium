AQ.FieldValue.record_methods.clear = function() {
  this.items = [];
  this.item = null;
  return this;
}

AQ.FieldValue.getter(AQ.Item,"item","child_item_id");

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

AQ.FieldValue.record_methods.find_items = function(sid) {

  var fv = this;

  AQ.items_for(sid,fv.aft.object_type_id).then( items => { 
    if ( items.length > 0 ) {                      
      fv.items = items;
      fv.items[0].selected = true;
      fv.selected_item = items[0];
      fv.sid = sid;
      AQ.update();
    }
  });

}