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

  if ( sample.sample_type ) {
    sample.sample_type = AQ.SampleType.record(sample.sample_type);
  }

  return this;

}

AQ.Sample.record_methods.field_value = function(name) {
  let sample = this;
  return aq.find(sample.field_values,fv => fv.name == name);
}

AQ.Sample.find_by_identifier = function(sid) {

  // This method is primarily used by the planner autocomplete method and planner assign methods, 
  // which is why it incluees field values (so subsamples can be looked up).

  if ( typeof sid == "string") {
    sample_id = AQ.id_from(sid);
  } else {
    sample_id = sid;
  }

  if ( sample_id ) {

    if ( AQ.sample_cache[sample_id] ) {

      return Promise.resolve(AQ.sample_cache[sample_id]);

    } else {

      let temp_sample = null;

      // get sid sample
      return AQ.Sample
        .where({id: sample_id}, {methods: ["field_values"], include: ["sample_type"]})
        .then(samples => {  // get the sample corresponding to sid
          if ( samples.length == 1 ) { // there should only be one       
            return samples[0];
          } else {
            raise("Sample " + sid + " not found");
          }
        })
        .then(sample => {
          AQ.sample_cache[sample.id] = sample;
          return sample;
        })
        .then(sample => {
          temp_sample = sample;
          return AQ.FieldType.where({parent_class: "SampleType", parent_id: sample.sample_type.id});
        })
        .then(field_types => {
          temp_sample.sample_type.field_types = field_types;
          return temp_sample;
        })

    }

  } else {
    console.log("Could not find sample " + sid)
    return Promise.reject("Could not find sample " + sid);
  }

}