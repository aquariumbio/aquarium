AQ.Item.getter(AQ.ObjectType,"object_type");
AQ.Item.getter(AQ.Sample,"sample");

AQ.Item.record_getters.url = function() {
  delete this.url;
  return this.url = "<a href='/items/" + this.id + "'>" + this.id + "</a>";
}

AQ.Item.record_methods.move = function(new_location) {

  var item = this;

  AQ.get("/items/move/" + item.id + "?location=" + new_location).then(response => {

    if ( response.data.message ) {
      item.location = new_location;
    } else if ( response.data.error ) {
      item.new_location = item.location;
      alert(response.data.error);
    }

  });

}

AQ.Collection.record_methods.move = AQ.Item.record_methods.move;

AQ.Item.record_getters.matrix = function() {

  var item = this;
  delete item.matrix;

  try {

    var data = JSON.parse(item.data);
    console.log(["data", data]);

    if ( data.matrix ) {
      item.matrix = data.matrix
    } 

  } catch(e) {}

  console.log(["matrix", item.matrix, item.data])

  return item.matrix;

}
