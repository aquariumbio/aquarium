AQ.Sample.record_getters.identifier = function() {
  var s = this;
  delete s.identifier;
  s.identifier = s.id + ": " + s.name;
  return s.identifier;
}

AQ.Sample.getter(AQ.User,"user");

AQ.Sample.getter(AQ.SampleType,"sample_type");

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

AQ.Sample.record_methods.complete_sample_type = function() {
  let sample = this;
  if ( AQ.sample_type_cache[sample.sample_type_id] ) {
    sample.sample_type = AQ.sample_type_cache[sample.sample_type_id];
    return sample;
  } else {
    return AQ.FieldType
      .where({parent_class: "SampleType", parent_id: sample.sample_type.id})
      .then(field_types => {
        sample.sample_type.field_types = field_types
        AQ.sample_type_cache[sample.sample_type_id] = sample.sample_type;
        return sample;
      })
  }  
}

/* This method is used by the planner autocomplete method and planner assign methods, 
 * which is why it incluees field values (so subsamples can be looked up).
 */
AQ.Sample.find_by_identifier = function(sid) {

  let sample_id = AQ.id_from(sid);

  if ( sample_id ) {

    if ( AQ.sample_cache[sample_id] ) {

      return Promise.resolve(AQ.sample_cache[sample_id]);

    } else {

      return AQ.Sample
        .where({id: sample_id}, {methods: ["field_values"], include: ["sample_type"]})
        .then(aq.first)
        .then(sample => sample.complete_sample_type())
        .then(sample => AQ.sample_cache[sample.id] = sample);

    }

  } else {

    return Promise.reject("Could not find sample " + sid);

  }

}