AQ.Collection.getter(AQ.ObjectType,"object_type");

AQ.Collection.record_getters.matrix = function() {

  var c = this;
  delete c.matrix;

  try {
    c.matrix = JSON.parse(c.data).matrix;
  } catch(e) {
    c.matrix = {};
  }

  return c.matrix;

}

AQ.Collection.record_methods.store = function() {

  var collection = this;

  AQ.get("/items/store/" + collection.id + ".json").then( response => {
    collection.location = response.data.location;
    collection.new_location = response.data.location;
  }).catch( response => {
    alert(response.data.error);
  })

}