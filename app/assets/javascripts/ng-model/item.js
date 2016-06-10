function Item(http) {
  this.http = http;
  return this;
}

Item.prototype.from = function(raw) {

  var item = this;

  for (var key in raw) { 
    this[key] = raw[key];
  }

  try {
    item.data = JSON.parse(item.data);
  } catch(e) {
    item.data = {};
  }

  PromoteDataAssociations(this);

  return this;

}
