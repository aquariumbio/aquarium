AQ.Base = function(model) {
  this.model = model;
  this.record_methods = {};
  this.record_getters = {};
  this.update = function() {};
  this.confirm = function() { return true; };
}

AQ.Base.prototype.super = function(name) {
  var base = this, args = [];
  for (var i=0;i<arguments.length-1;i++) args[i]=arguments[i+1];
  return base.__proto__[name].apply(base,args);
}

AQ.Base.prototype.record = function(extras) {
  let record = new AQ.Record(this,extras);
  if ( record.upgrade ) {
    record.upgrade(extras);
  }
  return record;
}

AQ.Base.prototype.find = function(id) {
  let base = this;
  // if ( base.model == "Item" ) {
  //   debugger;
  // }
  return new Promise(function(resolve,reject) {
    AQ.post('/json.json',{model: base.model, method: 'find', id: id}).then(
      (response) => {
        resolve(base.record(response.data));
      },(response) => {
        reject(response.data);
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

AQ.Base.prototype.array_query = function(method,args,rest,opts={}) {

  var base = this;
  var options = $.extend({offset: -1, limit: -1, reverse: false},opts);
  var query = { model: base.model, method: method, arguments: args, options: options };

  return new Promise(function(resolve,reject) {
    AQ.post('/json',$.extend(query,rest)).then(
      (response) => {
        var records = [];
        for (var i=0; i<response.data.length; i++ ) {
          records.push(base.record(response.data[i]));
        }
        resolve(records);
      },(response) => {
        reject(response.data);
      }
    );
  });

}

AQ.Base.prototype.all = function(rest={},limit=-1,opts={}) {
  var options = $.extend({offset: -1, limit: -1, reverse: false},opts);
  return this.array_query('all',[],rest,options);
}

AQ.Base.prototype.where = function(criteria,methods={},opts={}) {
  var options = $.extend({offset: -1, limit: -1, reverse: false},opts);
  return this.array_query('where',criteria,methods,options);
}

AQ.Base.prototype.exec = function(method, args) {
  var base = this;
  return new Promise(function(resolve,reject) {
    AQ.post('/json',{model: base.model, method: method, arguments: args}).then(
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
        if ( base[hidden_name].location ) {
          // This is a hack to get the item popup to properly initialize, since ng-init
          // in the location input box doesn't always work
          base[hidden_name].new_location = base[hidden_name].location;
        }
        AQ.update();
      });
      return null;
    } else {
      return null;
    }

  }

}

AQ.model_names = [
  "Account", "User", "Group", "SampleType", "Sample", "ObjectType", "Item", "UserBudgetAssociation", "Budget",
  "OperationType", "Operation", "FieldType", "FieldValue", "AllowableFieldType", "Wire", "Parameter",
  "Plan", "PlanAssociation", "DataAssociation", "Job", "Upload", "Code", "Timing", "Collection",
  "Library", "JobAssociation", "Locator", "PartAssociation" ];

for ( var i=0; i<AQ.model_names.length; i++ ) {
  AQ[AQ.model_names[i]] = new AQ.Base(AQ.model_names[i]);
}
