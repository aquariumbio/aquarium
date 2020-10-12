AQ.PartAssociation.record_methods.upgrade = function(raw_data) {

  let pa = this;

  if ( raw_data.part ) {
    pa.part = AQ.Item.record(pa.part);
  }
  if ( raw_data.collection ) {
    pa.collection = AQ.Collection.record(pa.collection);
  }

}
