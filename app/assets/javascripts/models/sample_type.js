AQ.SampleType.record_methods.sample_names = function(substring) {

  var st = this,
      sids;

  sids = aq.where(AQ.sample_names_for(this.name), sn => sn.includes(substring));

  return sids;
  
}

AQ.SampleType.record_methods.get_field_types = function() {

  let st = this;

  return AQ.FieldType.where({
    parent_class: "SampleType",
    parent_id: st.id
  });

}