AQ.Base = function(model) {
  this.model = model;
  this.record_methods = {};
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

AQ.model_names = [ 
  "User", "Group", "SampleType", "Sample", "ObjectType", "Item",
  "OperationType", "Operation", "FieldType", "FieldValue", "AllowableFieldType", 
  "Plan", "PlanAssociation" ];

for ( var i=0; i<AQ.model_names.length; i++ ) {
  AQ[AQ.model_names[i]] = new AQ.Base(AQ.model_names[i]);
}
