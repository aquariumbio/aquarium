AQ.Item.getter(AQ.ObjectType,"object_type");
AQ.Item.getter(AQ.Sample,"sample");

AQ.Item.record_getters.is_collection = function() {
  return (this.object_type.handler == 'collection');
}

AQ.Item.record_getters.is_part = function() {
  return (this.object_type.name == '__Part');
}

AQ.Item.record_getters.collection = function() {
  let item = this;
  if ( item.is_part ) {
    delete item.collection;
    AQ.PartAssociation
      .where({part_id: item.id}, {include: { collection: { include: "object_type" }}})
      .then(pas => {
        if ( pas.length == 1 ) {
          item.collection = pas[0].collection;
          item.row = pas[0].row;
          item.column = pas[0].column;
        }
      })
  } else {
    return undefined;
  }
}

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

  AQ.get(`/collections/${item.id}/raw_matrix`).then(response => {
    item.matrix = response.data;
  })

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

AQ.Collection.record_methods.mark_as_deleted = AQ.Item.record_methods.mark_as_deleted;

AQ.Item.record_methods.get_history = function() {

  var item = this;

  return AQ.get("/items/history/" + item.id)
    .then(response => {
      delete item.history;
      item.history = response.data;
      aq.each(item.history, h => {
        h.field_value = AQ.FieldValue.record(h.field_value);
        h.operation = AQ.Operation.record(h.operation);
        h.jobs = aq.collect(h.operation.jobs, job => {
          return AQ.Job.record(job);
        });
      });
      return item.history;
    })

}

AQ.Item.record_getters.history = function() {
  var item = this;
  delete item.history; 
  item.get_history();
  return item.history;
}

AQ.Item.record_getters.jobs = function() {

  var item = this;
  delete item.jobs; 
  item.jobs = [];

  function remove_dups(joblist) {
    let list = [];
    aq.each(joblist, job => {
      if ( aq.where(list, x => (x.id == job.id)).length == 0 ) {
        list.push(job);
      }
    })
    return list;
  }

  item.get_history().then(history => {
    aq.each(history, h => {
      item.jobs = item.jobs.concat(h.jobs);
    })
    item.jobs = remove_dups(item.jobs);
  });

  return item.jobs;

}

AQ.Collection.record_methods.get_history = AQ.Item.record_methods.get_history;
AQ.Collection.record_getters.history = AQ.Item.record_getters.history;
AQ.Collection.record_getters.jobs = AQ.Item.record_getters.jobs;


