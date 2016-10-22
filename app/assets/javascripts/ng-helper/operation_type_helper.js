function empty_goal(ot) {

  var result = {
    form_inputs: {},
    form_outputs: {}
  };

  aq.each(ot.field_types, function(ft) {

    var sort = "form_" + ft.role + "s";

    result[sort][ft.name] = {
      aft_id: 0,
      aft: {},
      sample: ft.array ? [] : "",
      role: ft.role
    }

    if ( ft.allowable_field_types.length > 0 ) {
      result[sort][ft.name].aft = ft.allowable_field_types[0];
      result[sort][ft.name].aft_id = ft.allowable_field_types[0].id;
    }

  });

  return result;

}
