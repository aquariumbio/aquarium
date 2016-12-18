AQ.Operation.record_methods.set_type = function(operation_type) {

  var op = this;
  op.operation_type_id = operation_type.id;
  op.operation_type = operation_type;
  op.field_values = [];

  aq.each(operation_type.field_types,function(ft) {
    var fv = new AQ.Record(AQ.FieldValue,{ name: ft.name, role: ft.role, items: [], routing: ft.routing, });
    if ( ft.allowable_field_types.length > 0 ) {
      fv.aft = ft.allowable_field_types[0];
      fv.aft_id = ft.allowable_field_types[0].id;
    }
    op.field_values.push(fv);
  });

}

AQ.Operation.record_methods.clear = function() {
  delete this.operation_type_id;
  delete this.operation_type;
  delete this.allowable_field_types;
}

AQ.Operation.record_methods.array_remove = function(fv) {

  var j = 0;

  while ( this.field_values[j] != fv ) {
    j++;
  }

  this.field_values.splice(j,1);
  this.update_cost();

}

AQ.Operation.record_methods.array_add = function(field_type) {

  var fv = new AQ.Record(AQ.FieldValue,{
    name: field_type.name, 
    role: field_type.role,
    routing: field_type.routing,
    items: []
  });

  if ( this.form && this.form[field_type.role] && this.form[field_type.role][field_type.name] ) {
    fv.aft = this.form[field_type.role][field_type.name].aft;
    fv.aft_id = this.form[field_type.role][field_type.name].aft_id;
  }

  this.field_values.push(fv);

  this.update_cost();

}

AQ.Operation.record_methods.each_field = function(callback) {

  var op = this;

  aq.each(op.operation_type.field_types,(ft) => {
    aq.each(op.field_values,(fv) => {
      if ( ft.name == fv.name && ft.role == fv.role ) {
        callback(ft,fv);
      }
    });
  });

}

AQ.Operation.record_methods.each_input = function(callback) {
  this.each_field((ft,fv) => {
    if ( ft.role == 'input' ) {
      callback(ft,fv);
    }
  })
}

AQ.Operation.record_methods.each_output = function(callback) {
  this.each_field((ft,fv) => {
    if ( ft.role == 'output' ) {
      callback(ft,fv);
    }
  })
}

AQ.Operation.record_methods.update_cost = function() {

  var op = this;

  AQ.post('/launcher/cost',op).then((result) => {
    op.cost = result.data.cost;
  }).catch( (problem) => {
    console.log(problem.data);
  });

}

