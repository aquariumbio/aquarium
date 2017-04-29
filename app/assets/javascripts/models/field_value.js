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

  return new Promise(function(resolve,reject) {    

    AQ.items_for(sid,fv.aft.object_type_id).then( items => { 

      if ( items.length > 0 ) {  
        fv.items = items;
        fv.items[0].selected = true;
        fv.selected_item = items[0];
        fv.sid = sid;
        AQ.update();
      } 

      resolve(items);

    });

  });

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

AQ.FieldValue.record_methods.backchain = function(plan,operation) {

  var fv = this;
  var pred = fv.preferred_predecessor();

  if ( plan.is_wired(operation,fv) ) {
    console.log("The input " + fv.name + " is already wired. delete existing subplan to replan.")
  } else if ( operation.form[fv.role][fv.name].aft.sample_type_id && ! fv.samp_id(operation) ) {
    console.log("The input " + fv.name + " does not have a sample assigned. fv.sid = " + fv.sample_identifier);
  } else if ( aq.where(fv.items, i => i.selected ).length > 0 ) {
    console.log("The input " + fv.name + " already has an item. Manually backchain to ignore it.");
  } else if ( !pred ) {
    console.log("The input " + fv.name + " has no preferred predecessor. Manually backchain to proceed.");    
  } else {
    var preop = plan.add_wire(fv,operation,pred);
    var output = aq.where(preop.field_values, fv => fv.role == 'output')[0];
    preop.instantiate(plan,output,output.samp_id(preop)).then( () => {    
      aq.each(preop.field_values, fv => {
        if ( fv.role == 'input' ) {
          var has_sample = preop.form[fv.role][fv.name].aft.sample_type_id;
          if ( has_sample && fv.samp_id(preop) ) {
            fv.find_items(fv.samp_id(preop)).then( items => {
              fv.backchain(plan,preop);
            });
          } else if ( !has_sample ) {
            fv.backchain(plan,preop);           
          } 
        }
      });
    });
  }

}
