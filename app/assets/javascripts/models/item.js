AQ.Item.getter(AQ.ObjectType,"object_type");
AQ.Item.getter(AQ.Sample,"sample");

AQ.Item.record_methods.upgrade = function() {

  let item = this;

  if ( item.sample ) {
    item.sample = AQ.Sample.record(item.sample);
  }
  if ( item.object_type ) {
    item.object_type = AQ.ObjectType.record(item.object_type);
  }

  item.new_location = item.location;

  item.recompute_getter("data_associations")

}

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

AQ.Item.record_methods.get_history = function() {

  var item = this;

  return new Promise(function(resolve, reject) {
    AQ.get("/items/history/" + item.id).then(response => {
      item.history = response.data;
      aq.each(item.history, h => {
        h.field_value = AQ.FieldValue.record(h.field_value);
        h.operation = AQ.Operation.record(h.operation);
        h.jobs = aq.collect(h.operation.jobs, job => {
          return AQ.Job.record(job);
        });
      });
      resolve(item.history);
    })  
  });

}

AQ.Item.record_getters.history = function() {
  var item = this;
  delete item.history; 
  item.get_history();
  return item.history;
}

AQ.Item.record_getters.is_collection = function() {
  return false;
}



