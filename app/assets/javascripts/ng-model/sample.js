function Sample(http) {
  this.http = http;
  return this;
}

Sample.prototype.find = function(id,promise) {

  var sample = this;

  this.http.get('/samples/' + id + '.json').then(function(response) {

    for (var key in response.data) { 
      sample[key] = response.data[key];
    }

    sample.promote_data();
    sample.sample_type = new SampleType(sample.http).from(sample.sample_type);
    sample.complete_fields();

    promise(sample);

  });

  return this;

}

Sample.prototype.get_inventory = function(promise) {

  var sample = this;

  this.http.get('/browser/items/' + this.id + '.json').then(function(response) {

    sample.containers = response.data.containers;    

    sample.items = aq.collect(response.data.items, function(raw) { 
      var i = AQ.Item.record(raw);
      console.log([i,i.data_associations])
      return i;
    });

    promise();

    sample.http.get('/browser/collections/' + sample.id + '.json').then(function(response) {
      sample.collections = aq.collect(response.data.collections, function(raw) {
        return AQ.Collection.record(raw);
      });
      sample.collection_containers = response.data.containers;
      
    });  

  });

}

Sample.prototype.num_items = function(container) {

  var sample = this;

  var items = aq.where(sample.items,function(i) {
    return ( sample.show_deleted || i.location != 'deleted' ) && i.object_type_id == container.id;
  });

  return items.length;

}

Sample.prototype.num_collections = function(container) {

  var sample = this;

  var collections = aq.where(sample.collections,function(c) {
    return ( sample.show_deleted || c.location != 'deleted' ) && c.object_type_id == container.id;
  });

  return collections.length;

}

Sample.prototype.visible_inventory = function() {

  var sample = this;

  var s = aq.sum(this.containers,function(con) {
    return sample.num_items(con) + sample.num_collections(con);
  });

  return s;

}

Sample.prototype.promote_data = function() {
  if ( typeof this.data == "string") {
    try {
      this.data = JSON.parse(this.data);
    } catch(e) {
      this.data = {};
    }
  } else if ( this.data == null ) {
    this.data = {};
  }  
}

Sample.prototype.from = function(raw) {

  for (var key in raw) { 
    this[key] = raw[key];
  }

  this.promote_data();
  this.sample_type = new SampleType(this.http).from(this.sample_type);
  this.complete_fields();

  return this;

}

Sample.prototype.complete_fields = function() {

  var sample = this;

  aq.each(this.field_values,function(fv) {
    var t = sample.type(fv.name);
    if ( t == 'number' ) {
      fv.value = parseFloat(fv.value);
    } else if ( t == 'sample' ) {
      if ( fv.child_sample ) {
        fv.child_sample = new Sample(sample.http).from(fv.child_sample);
        fv.child_sample_name = "" + fv.child_sample.id + ": " + fv.child_sample.name;
      }
      if ( !fv.allowable_child_types ) {
        fv.allowable_child_types = sample.allowable(fv.name);
      }
    } else if ( !t ) {
      fv.orphan = true;
    }
  });

  sample.set_defaults();

  return this;

}

Sample.prototype.allowable = function(field_name) {
  var ft = this.field_type(field_name);
  return aq.collect(ft.allowable_field_types,function(aft) {
    return aft.sample_type.name;
  });
}

Sample.prototype.set_defaults = function() {

  var sample = this;

  aq.each(this.sample_type.field_types,function(ft) {
    if ( !ft.array && sample.fields(ft.name).length == 0 ) {
      var fv = sample.sample_type.default_field(ft);
      fv.allowable_child_types = sample.allowable(fv.name);
      sample.field_values.push(fv);
    }
  });

  return this;

}

Sample.prototype.new = function(stid,promise) {

  var sample = this;

  new SampleType(this.http).find(stid,function(sample_type) {

    sample.name = "new_" + sample_type.name.toLowerCase();
    sample.description = "New sample type description";
    sample.field_values = [];
    sample.sample_type = sample_type;
    sample.sample_type_id = stid;
    sample.set_defaults();

    if ( promise ) {
      promise(sample);
    }

  });

  return this;

}

Sample.prototype.wipe = function()  {

  this.name = this.name + " (copy)";
  this.description = this.description + " (copy of sample no. " + this.id + ")";
  this.id = null;

  aq.each(this.field_values,function(fv) {
    fv.id = null;
  });

  return this;

}


Sample.prototype.fields = function(name) {
  var fvs = aq.where(this.field_values,function(fv) {
    return fv.name == name;
  });
  return fvs;
}

Sample.prototype.type = function(x) {
  var ft = this.field_type(x);
  if (ft) {
    return ft.ftype;
  } else {
    return null;
  }
}

Sample.prototype.field_type = function(x) {

  var name = typeof x == 'string' ? x : x.name;

  var fts = aq.where(this.sample_type.field_types,function(ft) {
    return ft.name == name;
  });

  if ( fts.length == 1 ) {
    return fts[0]
  } else {
    return null;
  }

}

Sample.prototype.update = function(promise) {
  this.http.put('/samples/' + this.id + '.json', { sample: this } )
    .then(function(response) {
       promise(response.data);
    });
  return this;
}

Sample.prototype.create = function(promise) {
  this.http.post('/samples.json', { sample: this } )
    .then(function(response) {
       promise(response.data);
    });
  return this;
}

Sample.prototype.field_value = function(name) {

  var fvs = aq.where(this.field_values,function(fv) {
    return fv.name == name;
  });

  if ( fvs.length == 1 ) {
    return fvs[0]
  } else {
    return null;
  }
}

Sample.prototype.lookup = function(name,sample_names,types,warnings) {

  for ( var st_name in sample_names ) {
    for ( var i=0; i<sample_names[st_name].length; i++ ) {
      var identifier = sample_names[st_name][i];
      if ( types.indexOf(st_name) >= 0 && ( identifier.split(": ")[0] == name || identifier.split(": ")[1] == name ) ) {
        return identifier;
      }
    }
  }

  warnings.push ( "Sample " + name + " was not found in among samples allowed for the given sample type and field." );
  return "UNKNOWN SUBSAMPLE " + name;

}

Sample.prototype.assign_fv_aux = function( t, fv, value, sample_names, warnings ) {

  var choices = null;

  if ( t.choices ) {
    choices = t.choices.split(',');    
  }

  if ( t.ftype == "number" ) {   
    var nchoices = aq.collect(choices,function(s) { return parseFloat(s); });
    if ( ! choices || nchoices.indexOf(parseInt(value)) >= 0 ) {
      fv.value = parseFloat(value);
    } else {
      warnings.push("Value for field " + t.name + " should be one of " + t.choices + ".")
    }
  } else if ( t.ftype == "sample" ) {
    if ( ! choices || choices.indexOf(value) >= 0 ) {    
      fv.child_sample_name = this.lookup(value, sample_names,fv.allowable_child_types,warnings);
    } else {
      warnings.push("Value for field " + t.name + " should be one of " + t.choices + ".")     
    }
  } else {
    fv.value = value;
  }

}

Sample.prototype.assign_field_value = function(name,value,sample_names,warnings) {

  var t = this.field_type(name),
      fv = this.field_value(name);

  if ( fv && !t.array ) {

    this.assign_fv_aux(t,fv,value,sample_names,warnings);

  } else if ( t && t.array && value != "" ) {

    var fv = this.sample_type.default_field(t);
    this.field_values.push(fv);
    this.assign_fv_aux(t,fv,value,sample_names,warnings);

  } else if ( t && t.array && value == ""  ) {

    // Do nothing, its an empty array field

  } else {

    warnings.push("Could not find field named '" + name + "'" + ".");

  }

}
