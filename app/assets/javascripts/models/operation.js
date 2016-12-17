AQ.Operation.record_methods.set_type = function(operation_type) {
  var op = this;
  op.operation_type_id = operation_type.id;
  op.operation_type = operation_type;
  op.field_values = [];
  aq.each(operation_type.field_types,function(ft) {
    var fv = { name: ft.name, role: ft.role, items: [] };
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
}

AQ.Operation.record_methods.array_add = function(field_type) {
  var fv = {
    name: field_type.name, 
    role: field_type.role,
    items: []
  };

  if ( this.form && this.form[field_type.role] && this.form[field_type.role][field_type.name] ) {
    fv.aft = this.form[field_type.role][field_type.name].aft;
    fv.aft_id = this.form[field_type.role][field_type.name].aft_id;
  }

  this.field_values.push(fv);

}