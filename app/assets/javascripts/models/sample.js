AQ.Sample.record_getters.identifier = function() {
  var s = this;
  delete s.identifier;
  s.identifier = s.id + ": " + s.name;
  return s.identifier;
}

AQ.Sample.getter(AQ.User,"user");

AQ.Sample.record_methods.upgrade = function() {

  let sample = this;

  if ( sample.field_values ) {
    for ( var i=0; i<sample.field_values.length; i++ ) {
      sample.field_values[i] = AQ.FieldValue.record(sample.field_values[i]);
    }
  }

  return this;

}

AQ.Sample.find_by_identifier = function(sid) {

  sample_id = AQ.id_from(sid);

  return new Promise(function(resolve, reject) {

    // get sid sample
    AQ.Sample.where({id: sample_id}, {methods: ["field_values"]}).then(samples => {  // get the sample corresponding to sid

      if ( samples.length == 1 ) { // there should only be one
        resolve(samples[0]);
      } else {
        reject("Sample " + sid + " not found");
      }

    }).catch(reject);

  });

}