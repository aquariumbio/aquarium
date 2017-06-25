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

    if ( data.matrix ) {
      item.matrix = data.matrix
    } 

  } catch(e) {}

  return item.matrix;

}

AQ.Item.record_methods.store = function() {

  var item = this;

  AQ.get("/items/store/" + item.id + ".json").then( response => {
    item.location = response.data.location;
    item.new_location = response.data.location;
  }).catch( response => {
    alert(response.data.error);
  })

}


AQ.Item.record_methods.mark_as_deleted = function() {

  var item = this;

  AQ.http.delete("/items/" + item.id + ".json").then( response => {
    item.location = "deleted"
    item.new_location = "deleted";
  }).catch( response => {    
    alert(response.data);
  })

}