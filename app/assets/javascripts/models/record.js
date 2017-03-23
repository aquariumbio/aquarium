AQ.Record = function(model,data) {

  var record = this;
  this.model = model;
  this._data_associations = []

  for ( var method_name in model.record_methods ) {
    record[method_name] = (function(mname) { 
      return function() { 
        var args = Array.prototype.slice.call(arguments);
        return model.record_methods[mname].apply(record,args);
      }
    })(method_name);
  }

  for ( var method_name in model.record_getters ) {
    Object.defineProperty(
      record, 
      method_name, 
      { 
        get: model.record_getters[method_name], 
        configurable: true 
      } 
    );
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

  record.rid = AQ.next_record_id++;

}

AQ.Record.prototype.recompute_getter = function(gname) {
  Object.defineProperty(this,gname,{get: this.model.record_getters[gname], configurable: true});
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
    AQ.post('/json/save',record,{withCredentials: true,processData: false}).then(
      (response) => { 
        if ( !record.id ) { 
          record.id = response.data.id; 
          record.created_at = response.data.created_at
        };
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

AQ.Record.prototype.drop = function(da) {

  aq.remove(this._data_associations,da);

}

AQ.Record.prototype.delete_data_association = function(da) {

  if ( AQ.confirm("Are you sure you want to delete this datum?") ) {

    da.delete().then(() => {
      aq.remove(this._data_associations,da);
      AQ.update();
    });

  }

}

AQ.Record.prototype.new_data_association = function() {

  var da = AQ.DataAssociation.record({
    unsaved: true,
    key: "key",
    value: undefined,
    new_value: "",
    parent_class: this.model.model,
    parent_id: this.id
  });

  this._data_associations.push(da);

  return da;

}
