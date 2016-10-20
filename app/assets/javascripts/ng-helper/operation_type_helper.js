function empty_goal(ot) {

  fvs = {};

  aq.each(ot.field_types, function(ft) {

    fvs[ft.name] = {
      sample: ft.array ? [] : "",
      aft: {},
      role: ft.role
    }

    if ( ft.allowable_field_types.length > 0 ) {
      fvs[ft.name].aft = ft.allowable_field_types[0];
    }

  })

  return { fvs: fvs };

}
