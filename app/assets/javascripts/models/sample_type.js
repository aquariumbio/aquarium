AQ.SampleType.record_methods.sample_names = function(substring) {

  var st = this,
      sids;

  sids = aq.where(AQ.sample_names_for(this.name), sn => sn.includes(substring));

  return sids;
  
}