AQ.Library.record_methods.code = function(name) {

  var lib = this;

  delete lib[name];
  lib[name]= { content: "Loading " + name, name: "name", no_edit: true };

  AQ.Code.where({parent_class: "Library", parent_id: lib.id, name: name}).then(codes => {
    if ( codes.length > 0 ) {
      latest = aq.where(codes,code => { return code.child_id == null });
      if ( latest.length >= 1 ) {
        lib[name] = latest[0];
      } else {
        lib[name]= { content: "# Add code here.", name: "name" };
      }
    } else { 
      lib[name]= { content: "# Add code here.", name: "name" };
    }
    AQ.update();
  });

  return lib[name];

}

AQ.Library.record_getters.source = function() {
  return this.code("source");
}

AQ.Library.record_getters.versions = function() {

  var lib = this;
  delete lib.versions;

  lib.versions = {
    source: []
  };

  AQ.Code.where({parent_class: "Library", parent_id: lib.id, name: 'source'}).then(list => {
    lib.versions = {
      source: list.reverse()
    };          
    AQ.update();
  });

  return lib.versions;

}