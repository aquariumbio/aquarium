function Sample(http) {
  this.http = http;
  return this;
}

Sample.prototype.find = function(id,promise) {

  var sample = this;

  this.http.get('/samples/' + id + '.json').then(function(response) {

    for (var key in response.data) { 
      sample[key] = response.data[key];
    }

    if ( typeof this.data == "string") {
      sample.data = JSON.parse(sample.data);
    } else if ( this.data == null ) {
      sample.data = {};
    }

    sample.sample_type = new SampleType(sample.http).from(sample.sample_type);
    sample.complete_fields();
    promise(sample);

  });

  return this;

}

Sample.prototype.complete_fields = function() {

  var sample = this;

  aq.each(this.field_values,function(fv) {
    var t = sample.type(fv.name);
    if ( t == 'number' ) {
      fv.value = parseFloat(fv.value);
    } else if ( t == 'sample' && fv.child_sample ) {
      fv.child_sample_name = "" + fv.child_sample.id + ": " + fv.child_sample.name;
    }
  });

  aq.each(this.sample_type.field_types,function(ft) {
    if ( !ft.array && sample.fields(ft.name).length == 0 ) {
      sample.field_values.push(sample.sample_type.default_field(ft));
    }
  });

  return this;

}

Sample.prototype.new = function(stid,promise) {

  var sample = this;

  new SampleType(this.http).find(stid,function(sample_type) {

    sample.name = "new_" + sample_type.name.toLowerCase();
    sample.description = "New sample type description";
    sample.field_values = sample_type.default_field_values();
    sample.sample_type = sample_type;
    sample.sample_type_id = stid;

    promise(sample);

  });

  return this;

}

Sample.prototype.fields = function(name) {
  var fvs = aq.where(this.field_values,function(fv) {
    return fv.name == name;
  });
  return fvs;
}

Sample.prototype.type = function(name) {

  var fts = aq.where(this.sample_type.field_types,function(ft) {
    return ft.name == name;
  });

  if ( fts.length == 1 ) {
    return fts[0].ftype;
  } else {
    return null;
  }

}

Sample.prototype.update = function(name) {
  console.log("update")
}


Sample.prototype.create = function(promise) {
  this.http.post('/samples.json', { sample: this } )
    .then(function(response) {
       promise(response.data);
    });
  return this;
}
