
function PromoteDataAssociations(parent) {

  var temp = parent.data_associations;
  parent.data_associations = [];

  aq.each(temp,function(da) {
    parent.data_associations.push(new DataAssociation(parent.http).from(da));
  });

}

function DataAssociation(http) {
  this.http = http;
  return this;
}

DataAssociation.prototype.from = function(raw) {

  for (var key in raw) { 
    this[key] = raw[key];
  }

  try {
    this.full_object = JSON.parse(this.object);
  } catch(e) {
    this.full_object = {};
    this.full_object[this.key] = null;
  }

  return this;

}

DataAssociation.prototype.value = function() {

  return this.full_object[this.key];

}

DataAssociation.prototype.set = function(val) {
  this.full_object = {};
  this.full_object[this.key] = val;
}