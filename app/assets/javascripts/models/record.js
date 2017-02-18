AQ.Record = function(model,data) {

  var record = this;
  this.model = model;

  for ( var method_name in model.record_methods ) {
    record[method_name] = (function(mname) { 
      return function() { 
        var args = Array.prototype.slice.call(arguments);
        return model.record_methods[mname].apply(record,args);
      }
    })(method_name);
  }

  for ( var method_name in model.record_getters ) {
    Object.defineProperty(record, method_name, { get: model.record_getters[method_name] } );
  }

  if ( data ) {
    record.init(data);
  }

  Object.defineProperty(record, "data_associations", { get: function() {
    if ( record._data_associations ) {
      return record._data_associations;
    } else  {
      record._data_associations = [];
      AQ.DataAssociation.where({parent_id: record.id, parent_class: model.model}).then((das) => {          
        record._data_associations = das;
        aq.each(record._data_associations,(da) => {
          da.value = JSON.parse(da.object)[da.key];
        });
        AQ.update();   
      });
      return null;
    } 
  }});

}

AQ.Record.prototype.init = function(data) {
  for ( var key in data ) {
    this[key] = data[key];
  }
  return this;
}

AQ.Record.prototype.save = function() {

  var record = this;

  return new Promise(function(resolve,reject) {  
    AQ.post('/json/save',record).then(
      (response) => { 
        if ( !record.id ) { record.id = response.data.id; };
        record.updated_at = response.data.updated_at;
        record.unsaved = null;
        resolve(record)
      },
      (response) => { reject(response.data.errors) }
    );
  });

}

AQ.Record.prototype.delete = function() {

  var record = this;

  return new Promise(function(resolve,reject) {  
    AQ.post('/json/delete',record).then(
      (response) => { resolve(record) },
      (response) => { reject(response.data.errors) }
    );
  });  

}

AQ.Record.prototype.delete_data_association = function(da) {

  da.delete().then(() => {
    aq.remove(this._data_associations,da);
    AQ.update();
  });

}

AQ.Record.prototype.new_data_association = function() {

  this._data_associations.push(AQ.DataAssociation.record({
    unsaved: true,
    key: "key",
    value: undefined,
    new_value: "",
    parent_class: this.model.model,
    parent_id: this.id
  }));

}



