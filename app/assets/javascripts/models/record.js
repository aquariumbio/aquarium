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

  if ( data ) {
    record.init(data);
  }

}

AQ.Record.prototype.init = function(data) {
  for ( var key in data ) {
    this[key] = data[key];
  }
  return this;
}