function Collection(http) {
  this.http = http;
  return this;
}

Collection.prototype.from = function(raw) {

  for (var key in raw) { 
    this[key] = raw[key];
  }

  try {
    this.data = JSON.parse(this.data);
  } catch(e) {
    this.data = {};
  }

  PromoteDataAssociations(this);

  return this;

}
