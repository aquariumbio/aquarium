
// BASE METHODS ============================================================

AQ.OperationType.compute_categories = function(ots) {

  ots.categories = aq.uniq(aq.collect(ots,function(ot) {
    return ot.category;
  }));

}

AQ.OperationType.all = function(rest) {

  return this.super('all',rest).then(
    (ots) => {
      this.compute_categories(ots);
      return ots;
    });

}

AQ.OperationType.all_with_content = function(deployed) {

  if ( deployed ) {

    return this.array_query(
        'where', {deployed: true}, 
        { methods: [ 'field_types', 'cost_model', 'documentation', 'timing' ] }
      ).then((ots) => {
        aq.each(ots,function(ot) { 
          ot.upgrade_field_types();
          if ( ot.timing ) {
            ot.timing = AQ.Timing.record(ot.timing);
          }
        })
        this.compute_categories(ots);
        return ots;
      });

  } else {

    return this.array_query(
        'all', [], 
        { methods: [ 'field_types', 'cost_model', 'documentation', 'timing' ] }
      ).then((ots) => {
        aq.each(ots,function(ot) { 
          ot.upgrade_field_types(); 
          if ( ot.timing ) {
            ot.timing = AQ.Timing.record(ot.timing);
          }          
        })
        this.compute_categories(ots);
        return ots;
      });

  }

}

AQ.OperationType.deployed_with_timing = function() {

  return new Promise(function(resolve, reject) {
    
    AQ.get("/operation_types/deployed_with_timing").then(raw_ots => {

      let ots = aq.collect(raw_ots.data, raw_ot => {
        let ot = AQ.OperationType.record(raw_ot);
        ot.timing = AQ.Timing.record(ot.timing);
        return ot;        
      });

      console.log(raw_ots)

      resolve(ots);

    })

  });

}

AQ.OperationType.all_fast = function(deployed_only=false) {

  return new Promise(function(resolve, reject) {

    AQ.get("/plans/operation_types/"+deployed_only).then( response => {

      ots = aq.collect(response.data, rot => {
        var ot = AQ.OperationType.record(rot);
        ot.upgrade_field_types();
        return ot;
      });

      resolve(ots);

    }).catch(reject);

  });

}

AQ.OperationType.all_with_field_types = AQ.OperationType.all_fast;

AQ.OperationType.numbers = function(user,filter) {

  var id = user ? user.id : null;

  return new Promise(function(resolve,resject) {
    AQ.get("/operation_types/numbers/" + id + "/" + filter).then(response => {
      resolve(response.data);
    })
  });

}

// RECORD METHODS ==================================================

AQ.OperationType.record_methods.upgrade_field_types = function() {
  this.field_types = aq.collect(this.field_types,(ft) => { 
    var upgraded_ft = AQ.FieldType.record(ft);
    upgraded_ft.allowable_field_types = aq.collect(ft.allowable_field_types, aft => {
      var uaft = AQ.AllowableFieldType.record(aft);
      uaft.upgrade();
      return uaft;
    });
    if ( ft.allowable_field_types.length > 0 ) {
      upgraded_ft.current_aft_id = ft.allowable_field_types[0].id;
    }
    return upgraded_ft;
  });
}

AQ.OperationType.record_methods.num_inputs = function() {
  return aq.where(this.field_types,(ft) => { return ft.role === 'input' }).length;
}

AQ.OperationType.record_methods.num_outputs = function() {
  return aq.where(this.field_types,(ft) => { return ft.role === 'output' }).length;
}

AQ.OperationType.record_methods.new_operation = function() {
  return new Promise(function(resolve,reject) {
    resolve("New Operation");
  });
}

AQ.OperationType.record_getters.stats = function() {

  var ot = this;

  delete ot.stats;
  ot.stats = {};
  
  AQ.get("/operation_types/"+ot.id+"/stats").then((response) => {
    ot.stats = response.data;
  }).catch((response) => {
    console.log(["error", response.data]);
  })

  return {};

}

AQ.OperationType.record_methods.schedule = function(operations) {

  var op_ids = aq.collect(operations,(op) => {
    return op.id;
  });

  return new Promise(function(resolve,reject) {

    AQ.post("/operations/batch", { operation_ids: op_ids }).then(
      response => resolve(response.data.operations),
      response => reject(response.data.operations)
    );

  });

}

AQ.OperationType.record_methods.unschedule = function(operations) {

  var op_ids = aq.collect(operations,(op) => {
    return op.id;
  });

  return new Promise(function(resolve,reject) {

    AQ.post("/operations/unbatch", { operation_ids: op_ids }).then(
      response => resolve(response.data.operations),
      response => reject(response.data.operations)
    );

  });

}

/*
 * Returns the named component: protocol, documentation, cost_model, or precondition.
 */
AQ.OperationType.record_methods.code = function(component_name) {

  var operation_type = this;

  delete operation_type[component_name];
  operation_type[component_name]= { content: "Loading " + component_name, name: "name", no_edit: true };

  AQ.Code.where({parent_class: "OperationType", parent_id: operation_type.id, name: component_name}).then(codes => {
    if ( codes.length > 0 ) {
      operation_type[component_name] = codes[codes.length-1];
    } else { 
      operation_type[component_name]= { content: "# Add code here.", name: "name" };
    }
    AQ.update();
  });

  return operation_type[component_name];

}

AQ.OperationType.record_getters.protocol = function() {
  return this.code("protocol");
}

AQ.OperationType.record_getters.documentation = function() {
  return this.code("documentation");
}

AQ.OperationType.record_getters.cost_model = function() {
  return this.code("cost_model");
}

AQ.OperationType.record_getters.precondition = function() {
  return this.code("precondition");
}

AQ.OperationType.record_getters.field_types = function() {
  
  var ot = this;
  delete ot.field_types;
  ot.field_types = [];
  ot.loading_field_types = true;

  AQ.FieldType.where({parent_class: "OperationType", parent_id: ot.id}).then(fts => {
    ot.field_types = fts;
    ot.loading_field_types = false;
    AQ.update();
  });

  return ot.field_types;

}

AQ.OperationType.record_getters.versions = function() {

  var ot = this;
  delete ot.versions;
  ot.versions = {
    protocol: [],
    cost_model: [],
    precondition: [],
    documentation: []
  };

  AQ.Code.where({parent_class: "OperationType", parent_id: ot.id, name: 'protocol'}).then(protocols => {
    AQ.Code.where({parent_class: "OperationType", parent_id: ot.id, name: 'precondition'}).then(pres => {
      AQ.Code.where({parent_class: "OperationType", parent_id: ot.id, name: 'cost_model'}).then(costs => {
        AQ.Code.where({parent_class: "OperationType", parent_id: ot.id, name: 'documentation'}).then(docs => {
          ot.versions = {
            protocol: protocols.reverse(),
            cost_model: costs.reverse(),
            precondition: pres.reverse(),
            documentation: docs.reverse()
          };          
          AQ.update();
        });
      });
    });
  });

  return ot.versions;

}

AQ.OperationType.record_methods.remove_predecessors = function() {
  // This method can be used to remove references to predecessors in field types
  // so that the resulting object is guaranteed not to be circular
  var ot = this;
  aq.each(ot.field_types,ft => {
    delete ft.predecessors;
  });
  return ot;
}

AQ.OperationType.record_getters.rendered_docs = function() {

  var ot = this;
  var md = window.markdownit();
  var docs = "Rendering..."

  delete ot.rendered_docs;

  AQ.Code.where({parent_class: "OperationType", parent_id: ot.id, name: 'documentation'}).then(codes => {

    if ( codes.length > 0 ) {
      latest = aq.where(codes,code => { return code.child_id == null });
      if ( latest.length >= 1 ) {
        docs = latest[0].content;
      } else {
        docs = "This operation type has not yet been documented";
      }
    } else { 
      docs = "This operation type has not yet been documented";
    }

    ot.rendered_docs = AQ.sce.trustAsHtml(md.render(docs));

    AQ.update();

  });

  return AQ.sce.trustAsHtml("Rendering ...");

}

AQ.OperationType.record_methods.set_default_timing = function() {
  var ot = this;
  ot.timing = AQ.Timing.default();
  ot.timing.parent_class = "OperationType";
  ot.timing.parent_id = ot.id;
  return ot;
}

AQ.OperationType.timing_sort_compare = function(ot1, ot2) {
  return (ot1.timing ? ot1.timing.start : 10000) - (ot2.timing ? ot2.timing.start : 10000)
}

AQ.OperationType.sort_by_timing = function(ots) {
  return ots.sort(AQ.OperationType.timing_sort_compare);
}
