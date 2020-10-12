AQ.Locator.getter(AQ.Item,"item");

AQ.Locator.record_methods.upgrade = function(raw_data) {

  let locator = this;

  if ( raw_data.item ) {
    locator.item = AQ.Item.record(raw_data.item);
  }

}