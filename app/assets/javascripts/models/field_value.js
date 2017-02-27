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
      console.log("checking " + ot.name + " / " + ft.name );
      if ( ft.role == 'output' && ft.can_produce(fv) ) {
        preds.push({operation_type: ot, output: ft});
        console.log("ok!")
      } else {
        console.log("nope")
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