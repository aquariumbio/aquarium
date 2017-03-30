AQ.FieldType.record_methods.sample_type_names = function() {
  var ft = this;
  return aq.collect(
           aq.where(ft.allowable_field_types, function(aft) { return aft.sample_type; }),
           function(aft) { return aft.sample_type.name; }
         );
}

AQ.FieldType.record_methods.chosen_sample_type_name = function() {

  var ft = this;

  for ( var i=0; i< ft.allowable_field_types.length; i++ ) {
    if ( ft.allowable_field_types[i].id == ft.aft_choice ) {
      if ( ft.allowable_field_types[i].sample_type ) {
        return ft.allowable_field_types[i].sample_type.name;
      } else {
        return null;
      }
    }
  }

  return null;

}

AQ.FieldType.record_methods.matches = function(field_value) {
  return field_value.role == this.role && field_value.name == this.name;
}

AQ.FieldType.record_methods.can_produce = function(fv) {

  var ft = this,
      rval = false;

  if ( ft.ftype == "sample" && fv.field_type.ftype == "sample" ) {

    aq.each(ft.allowable_field_types, (aft) => {
      if ( fv.aft.sample_type_id == aft.sample_type_id &&
           fv.aft.object_type_id == aft.object_type_id && 
           Number(fv.field_type.part) == Number(ft.part) ) { // Note, Number is used to compare null and false
        rval = true;
      }
    });

  } else { 

    rval = false;

  }

  return rval;

}

AQ.FieldType.record_getters.choices_array = function() {

  var ft = this;
  delete ft.choices_array;
  if ( ft.choices ) {
    ft.choices_array = ft.choices.split(',');
  } else {
    ft.choices_array = [];
  }
  return ft.choices_array;

}

AQ.FieldType.record_getters.predecessors = function() {

  var ft = this;
  var preds = [];

  delete ft.predecessors;

  aq.each(AQ.operation_types, ot => {
    aq.each(ot.field_types, other_ft => {
      if ( other_ft.role == 'output' ) {
        aq.each(ft.allowable_field_types, aft => {
          aq.each(other_ft.allowable_field_types, other_aft => {
            if ( aft.sample_type_id == other_aft.sample_type_id &&
                 aft.object_type_id == other_aft.object_type_id && 
                 Number(ft.part) == Number(other_ft.part) ) { // Note, Number is used to compare null and false
              preds.push({operation_type: ot, field_type: other_ft});
            }          
          });
        });
      }
    });
  });

  ft.predecessors = preds;

  return preds;

}
