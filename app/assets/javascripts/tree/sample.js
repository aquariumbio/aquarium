function Sample(sample_type) {
  this.copy = {};
  this.edit = false;
  this.sample_type = sample_type;
  this.data = {};
  return this;
}

Sample.prototype.from = function(sample) {

  for (var key in sample) { 
    this[key] = sample[key];
  }
  if ( typeof this.data == "string") {
    this.data = JSON.parse(this.data);
  } else if ( this.data == null ) {
    this.data = {};
  }
  return this;

}

Sample.prototype.field_type = function(i) {
  return this.sample_type["field"+i+"type"];
}

Sample.prototype.field_name = function(i) {
  return this.sample_type["field"+i+"name"];
}

Sample.prototype.key= function(i) {
  return "field"+i;
}

Sample.prototype.prepare_copy = function() {

  this.copy = {
    name: this.name,
    description: this.description,
    project: this.project
  }

  if ( this.sample_type ) {
    for ( var i=1; i<=8; i++ ) {
      this.copy["field"+i] = this.field_copy(i);
    }
  } else {
    throw "Could not prepare fields without sample_type."
  }

  return this;

}

Sample.prototype.subsample_identifier = function(i) {
  var ss = this.subsamples[this.field_name(i)];
  if ( ss && ss.id ) {
    return ss.id + ": " + ss.name;
  } else {
    return "";
  }
}

Sample.prototype.field_copy = function(i) {
  if ( this.field_type(i) == 'url' || this.field_type(i) == 'string') {
    return this[this.key(i)];
  } else if ( this.field_type(i) == 'number' ) {
    return parseInt(this[this.key(i)]);
  } else {
    return { choice: "existing", existing: this.subsample_identifier(i), new: null };
  }
}

Sample.prototype.default_field = function(i) {
  if ( this.field_type(i) == 'url' ) {
    return "http://";
  } else if ( this.field_type(i) == 'number' ) {
    return 0;
  } else if ( this.field_type(i) == 'string' ) {
    return "";
  } else {
    return { choice: "existing", existing: "", new: null };
  }
}

Sample.prototype.toggle_new_existing = function(i) {
  if ( this.copy[this.key(i)].choice == 'existing' ) {
    this.copy[this.key(i)].choice = 'new';
  } else {
    this.copy[this.key(i)].choice = 'existing';
  }
  return this;
}

Sample.prototype.empty = function(sample_type,project) {

  this.sample_type = sample_type;

  this.copy = {
    name: sample_type.name.toLowerCase(),
    description: "Description of new " + sample_type.name.toLowerCase() + " here",
    project: project
  }

  for ( var i=1; i<=8; i++ ) {
    this.copy[this.key(i)] = this.default_field(i);
  }

  return this;

}

Sample.prototype.fields = function() {
  for ( var i=1; i<=8; i++ ) {
    
  }
}


