function SampleType(http) {
  this.http = http;
  return this;
}

SampleType.prototype.find = function(id,promise) {

  var sample_type = this;

  this.http.get('/sample_types/' + id + '.json').then(function(response) {
    sample_type.from(response.data);
    promise(sample_type);
  });

}

SampleType.prototype.from = function(raw) {

  for (var key in raw) { 
    this[key] = raw[key];
  } 

  this.setup_types_arrays();

  return this; 

}

SampleType.prototype.setup_types_arrays = function() {

  aq.each(this.field_types,function(ft) {
    ft.types = [];
    aq.collect(ft.allowable_field_types,function(aft) {
      ft.types.push(aft.sample_type.name);
    });
    if ( ft.choices ) {
      ft.choices_array = ft.choices.split(",");
      if ( ft.ftype == "number" ) {
        ft.choices_array = aq.collect(ft.choices_array,function(c) { return parseFloat(c); });
      }
    }
  });

  return this;

}

SampleType.prototype.default_field = function(field_type) {

  var defs = {
    string: "",
    number: 0,
    url: "http://please.link.your.sequences.com",
    sample: ""
  };

  if ( field_type.ftype == 'sample' ) {
    return { name: field_type.name, child_sample_name: defs[field_type.ftype]};
  } else if ( field_type.ftype == 'string' && field_type.choices ) {
    return { name: field_type.name, value: field_type.choices_array[0] };
  } else if ( field_type.ftype == 'number' && field_type.choices ) {
    return { name: field_type.name, value: parseFloat(field_type.choices_array[0]) };
  } else {
    return {name: field_type.name, value: defs[field_type.ftype]};
  }

}

SampleType.prototype.default_field_values = function() {

  var sample_type = this;

  return aq.collect(this.field_types,function(ft) {
    return sample_type.default_field(ft);
  });

}

SampleType.prototype.field_type = function(name) {
  var fts = aq.where(this.field_types,function(ft) {
    return ft.name == name;
  });
  if ( fts.length > 0 ) {
    return fts[0]
  } else {
    return null;
  }
}