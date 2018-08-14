AQ.Item.getter(AQ.ObjectType,"object_type");
AQ.Item.getter(AQ.Sample,"sample");

AQ.Item.record_methods.upgrade = function(raw_data) {

  let item = this;

  if ( raw_data.sample ) {
    item.sample = AQ.Sample.record(item.sample);
  }

  if ( raw_data.object_type ) {
    item.object_type = AQ.ObjectType.record(item.object_type);
  }

  item.new_location = item.location;

  // item.recompute_getter("data_associations")

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


AQ.Item.record_methods.request_delete = function() {

  var item = this;

  var da = AQ.DataAssociation.record({
    unsaved: true,
    key: "delete_requested",
    value:"This item is marked for discard and will not be used in operations." ,
    new_value: "This item is marked for discard and will not be used in operations.",
    parent_class: item.model.model,
    parent_id: item.id
  });

  if ( typeof item.data_associations === "object" ) {
    item.data_associations.push(da);
  }

  var temp = {},
  old_object = da.object;
  temp[da.key] = da.new_value;
  da.object = JSON.stringify(temp);
  da.new_value = "This item is marked for discard and will not be used in operations."
  da.save()
    .then(() => { da.value = da.new_value, AQ.update() })
    .catch(() => { da.object = old_object; })
}


AQ.Item.record_methods.approve_sequencing = function() {

  var item = this;

  var da = AQ.DataAssociation.record({
    unsaved: true,
    key: "sequencing_approved",
    value:"Sequencing results for this item have been approved by the user." ,
    new_value: "Sequencing results for this item have been approved by the user.",
    parent_class: item.model.model,
    parent_id: item.id
  });

  if ( typeof item.data_associations === "object" ) {
    item.data_associations.push(da);
  }

  var temp = {},
  old_object = da.object;
  temp[da.key] = da.new_value;
  da.object = JSON.stringify(temp);
  da.new_value = "Sequencing results for this item have been approved by the user."
  da.save()
    .then(() => { da.value = da.new_value, AQ.update() })
    .catch(() => { da.object = old_object; })
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



AQ.Item.record_getters.has_sequencing = function() {
  var item = this;
  console.log("Reached function AQ.Item.record_gettters.has_sequencing...");
  console.log(item.data_associations);
  if (item.data_associations.some( da => da.key === "sequencing_results")) {
    return true;
  } else {
    return false;
  }
}
