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

