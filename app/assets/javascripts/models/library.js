AQ.Library.record_methods.code = function(component_name) {

  let lib = this;

  delete lib[component_name];
  lib[component_name]= { content: "Loading " + component_name, name: "name", no_edit: true };

  AQ.Code.where({parent_class: "Library", parent_id: lib.id, name: component_name}).then(codes => {
    if ( codes.length > 0 ) {
      lib[component_name] = codes[codes.length-1];
     } else { 
      lib[component_name]= { content: "# Add code here.", name: "name" };
    }
    AQ.update();
  });

  return lib[component_name];

};

AQ.Library.record_getters.source = function() {
  return this.code("source");
};

AQ.Library.record_getters.versions = function() {

  let lib = this;
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

};