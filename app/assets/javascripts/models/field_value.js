
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
        console.log("found predecessor: " + ot.name);
        preds.push({operation_type: ot, output: ft});
      }
    });
  });

  delete fv.predecessors;
  fv.predecessors = preds;
  return preds;

}
