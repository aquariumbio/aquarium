function SampleHelper(http) {
  this.http = http;
}

SampleHelper.prototype.autocomplete = function(promise) {

  this.http.get("/browser/all").then(function(response) {
    promise(response.data);
  });

  return this;
  
}

SampleHelper.prototype.samples = function(project,sample_type_id,promise) {

  var sample_helper = this;

  this.http.get('/browser/samples_for_tree.json?project='+project+"&sample_type_id="+sample_type_id)
    .then(function(response) {
      var upgraded_samples = aq.collect(response.data,function(raw_sample) {
        return new Sample(sample_helper.http).from(raw_sample);
      });      
      promise(upgraded_samples);
    });      

  return this;

}

SampleHelper.prototype.recent_samples = function(uid,promise) {

  var sample_helper = this;

  this.http.get('/browser/recent_samples/'+uid)
    .then(function(response) {
      var upgraded_samples = aq.collect(response.data,function(raw_sample) {
        return new Sample(sample_helper.http).from(raw_sample);
      });      
      promise(upgraded_samples);
    });      

  return this;

}

SampleHelper.prototype.create_samples = function(samples,promise) {
  this.http.post('/browser/create_samples', { samples: samples }).then(function(response) {
    promise(response.data);
  });
  return this;
}

SampleHelper.prototype.spreadsheet = function(http,sample_types, sample_names, csv) {

  var lines = csv.split(/\r|\n/),
      headers = lines[0].split(','),
      rows = lines.splice(1,lines.length),
      sample_type_name = headers[0],
      matches = aq.where(sample_types,function(st) { return st.name == sample_type_name; } ),
      sample_type,
      samples = [],
      warnings = [];

  if ( matches.length > 0 ) {
    sample_type = matches[0];
  } else {
    throw("Could not find sample type " + sample_type_name);
  }

  aq.each(rows,function(row,i) {

    var fields = row.split(',');

    if ( fields.length > 1 ) {

      (new Sample(http)).new(sample_type.id, function(sample) {

        aq.each(headers,function(header,j) {

          if ( header == sample_type_name ) {
            sample.name = fields[j];
          } else if ( header == "Description" ) {
            sample.description = fields[j];
          } else if ( header == "Project" ) {
            sample.project = fields[j];
          } else {
            sample.assign_field_value(header,fields[j],sample_names,warnings);
          }

        });

        samples.push(sample);

      });

    }

  });

  return { samples: samples, warnings: warnings };

}