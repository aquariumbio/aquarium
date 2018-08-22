AQ.PartAssociation.record_methods.upgrade = function(raw_data) {

  let pa = this;

  if ( raw_data.part ) {
    pa.part = AQ.Item.record(pa.part);
  }

}