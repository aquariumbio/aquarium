AQ.Base = function(model) {
  this.model = model;
  this.record_methods = {};
  this.record_getters = {};
  this.update = function() {};
}

AQ.Base.prototype.super = function(name) {
  var base = this;
  return base.__proto__[name].apply(base,arguments);
}

AQ.Base.prototype.record = function(extras) {
  return new AQ.Record(this,extras);
}

AQ.Base.prototype.find = function(id) {
  var base = this;
  return new Promise(function(resolve,reject) {
    AQ.post('/json',{model: base.model, id: id}).then(
      (response) => {
        resolve(base.record(response.data));
      },(response) => {
        reject(response.data.errors);
      }
    );
  });
}

AQ.Base.prototype.find_by_name = function(name) {
  var base = this;
  return new Promise(function(resolve,reject) {  
    AQ.post('/json',{model: base.model, method: 'find_by_name', arguments: [ name ] }).then(
      (response) => {
        resolve(base.record(response.data));
      },(response) => {
        reject(response.data.errors);
      }
    );
  });
}

AQ.Base.prototype.array_query = function(method,arguments,rest) {

  var base = this;
  var query = { model: base.model, method: method, arguments: arguments };

  return new Promise(function(resolve,reject) {
    AQ.post('/json',$.extend(query,rest)).then(
      (response) => {
        var records = [];
        for (var i=0; i<response.data.length; i++ ) {
          records.push(base.record(response.data[i]));
        }
        resolve(records);
      },(response) => {
        reject(response.data.errors);
      }
    );
  });

}

AQ.Base.prototype.all = function() {
  return this.array_query('all',[]);
}

AQ.Base.prototype.where = function(criteria,methods={}) {
  return this.array_query('where',criteria,methods);
}

AQ.Base.prototype.exec = function(method, arguments) {
  var base = this;
  return new Promise(function(resolve,reject) {  
    AQ.post('/json',{model: base.model, method: method, arguments: arguments}).then(
      (response) => { resolve(response.data) },
      (response) => { reject(response.data.errors) }
    );
  });
}

AQ.Base.prototype.new = function() {
  var base = this;
  return new Promise(function(resolve,reject) {    
    AQ.post('/json',{model: base.model, method: 'new'}).then(
      (response) => {
        resolve(base.record(response.data));
      }, (response) => {
        reject(response.data.errors);
      }
    );  
  });
}

AQ.Base.prototype.getter = function(child_model, child_name,id=null) {

  var hidden_name = "_" + child_name,
      id_name = id ? id : child_name + "_id";

  this.record_getters[child_name] = function() {

    var base = this;

    if ( base[hidden_name] ) {
      return base[hidden_name];
    } else if ( base[id_name] ) {
      base[hidden_name] = {};    
      child_model.find(base[id_name]).then((x) => { 
        base[hidden_name] = x;
        AQ.update();
      });    
      return null;  
    } else {
      return null;
    }

  }

}

AQ.model_names = [ 
  "User", "Group", "SampleType", "Sample", "ObjectType", "Item",
  "OperationType", "Operation", "FieldType", "FieldValue", "AllowableFieldType", 
  "Plan", "PlanAssociation", "DataAssociation", "Job" ];

for ( var i=0; i<AQ.model_names.length; i++ ) {
  AQ[AQ.model_names[i]] = new AQ.Base(AQ.model_names[i]);
}
