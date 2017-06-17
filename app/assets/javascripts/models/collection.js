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