AQ.Operation.record_methods.set_type = function(operation_type) {
  this.operation_type_id = operation_type.id;
  this.operation_type = operation_type;
}

AQ.Operation.record_methods.clear = function() {
  delete this.operation_type_id;
  delete this.operation_type;
  delete this.allowable_field_types;
}

AQ.Operation.record_methods.delete_array_field_value = function(field_type,role,index) {
  var j = 0;
  for ( var i=0; i<this.field_values.length; i++ ) {
    if ( this.field_values.name == field_type.name && 
         this.field_values.role == field_type.role && 
         j < index ) {
      j++;
    }
  }
  this.field_values.splice(j,1);
}

AQ.Operation.record_methods.add_array_field_value = function(field_type,role) {
  this.field_values.push({
    name: field_type.name, 
    role: field_type.role
  });
}