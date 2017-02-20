AQ.Item.getter(AQ.ObjectType,"object_type");

AQ.Item.record_getters.url = function() {
  delete this.url;
  return this.url = "<a href='/items/" + this.id + "'>" + this.id + "</a>";
}