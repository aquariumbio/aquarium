AQ.Item.getter(AQ.ObjectType,"object_type");

AQ.Item.record_getters.url = function() {
  return "<a href='/items/" + this.id + "'>" + this.id + "</a>";
}