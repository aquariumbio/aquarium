AQ.Operation.record_methods.set_type = function(operation_type) {

  var op = this;
  op.operation_type_id = operation_type.id;
  op.operation_type = operation_type;
  op.field_values = [];

  aq.each(operation_type.field_types, ft => {

    var fv = AQ.FieldValue.record({ 
      name: ft.name, 
      role: ft.role, 
      items: [],
      routing: ft.routing,
      field_type: ft
    });

    if ( ft.allowable_field_types.length > 0 ) {
      fv.aft = ft.allowable_field_types[0];
      fv.aft_id = ft.allowable_field_types[0].id;
    }

    op.field_values.push(fv);

    if ( ft.allowable_field_types.length > 0 ) {
      op.set_aft(ft,ft.allowable_field_types[0])
    }

  });

  return this;

}

AQ.Operation.record_getters.field_values = function() {

  var op = this;
  delete op.field_values;

  AQ.FieldValue.where({parent_class: "Operation", parent_id: op.id}).then(fvs => {
    op.field_values = fvs;
    AQ.update();
  })

  return undefined;

}

AQ.Operation.record_methods.set_type_with_field_values = function(operation_type,fvs) {

  var op = this;
  op.operation_type_id = operation_type.id;
  op.operation_type = operation_type;
  op.field_values = [];
  op.routing = {};

  aq.each(operation_type.field_types, ft => {

    aq.each(fvs, old_fv => {

      if ( old_fv.role == ft.role && old_fv.name == ft.name ) {

        var fv = AQ.FieldValue.record({
          name: ft.name, 
          role: ft.role, 
          items: [],
          routing: ft.routing,
          field_type: ft,
          id: old_fv.id,
          child_sample: old_fv.child_sample
        });     

        if ( ft.allowable_field_types.length > 0 ) {
          fv.aft = ft.allowable_field_types[0];
          fv.aft_id = ft.allowable_field_types[0].id;
        }

        op.field_values.push(fv);

        if ( ft.allowable_field_types.length > 0 ) {
          op.set_aft(ft,ft.allowable_field_types[0])
        }

        if ( ft.array ) {
          fv.sample_identifier = fv.sid(); 
        } else {
          op.routing[ft.routing] = fv.sid(); 
        }

        if ( fv.sid() != "" ) {
          fv.find_items(fv.sid());
        }

      }

    });

  });

  return this;

}

AQ.Operation.record_methods.set_aft = function(ft,aft) {
  var op = this;
  op.form[ft.role][ft.name] = { aft_id: aft.id, aft: aft };
  aq.each(op.field_values,function(fv) {
    if ( fv.name == ft.name && fv.role == ft.role ) {
      op.routing[ft.routing] = '';
      fv.aft = aft;
      fv.aft_id = aft.id;
      fv.items = [];
      fv.field_type = ft;
      fv.recompute_getter('predecessors');
    }
  });
}

AQ.Operation.record_methods.clear = function() {
  delete this.operation_type_id;
  delete this.operation_type;
  delete this.allowable_field_types;
  return this;
}

AQ.Operation.record_methods.array_remove = function(fv) {

  var j = 0;

  while ( this.field_values[j] != fv ) {
    j++;
  }

  this.field_values.splice(j,1);
  this.recompute_getter('types_and_values');
  return this;

}

AQ.Operation.record_methods.array_add = function(field_type) {

  var fv = AQ.FieldValue.record({
    name: field_type.name, 
    role: field_type.role,
    routing: field_type.routing,
    items: [],
    field_type: field_type
  });

  if ( this.form && this.form[field_type.role] && this.form[field_type.role][field_type.name] ) {
    fv.aft = this.form[field_type.role][field_type.name].aft;
    fv.aft_id = this.form[field_type.role][field_type.name].aft_id;
  }

  this.field_values.push(fv);

  this.recompute_getter('types_and_values');

  return this;

}

AQ.Operation.record_methods.each_field = function(callback) {

  var op = this;

  aq.each(op.operation_type.field_types,(ft) => {
    aq.each(op.field_values,(fv) => {
      if ( ft.name == fv.name && ft.role == fv.role ) {
        callback(ft,fv);
      }
    });
  });

  return this;

}

AQ.Operation.record_methods.each_input = function(callback) {
  this.each_field((ft,fv) => {
    if ( ft.role == 'input' ) {
      callback(ft,fv);
    }
  })
  return this;

}

AQ.Operation.record_methods.each_output = function(callback) {
  this.each_field((ft,fv) => {
    if ( ft.role == 'output' ) {
      callback(ft,fv);
    }
  })
  return this;

}

AQ.Operation.record_methods.update_cost = function() {

  var op = this;

  AQ.post('/launcher/cost',op).then((result) => {
    op.cost = result.data.cost;
  }).catch( (problem) => {
  });

  return this;

}

AQ.Operation.record_methods.output = function(name) {

  var fvs = aq.where(
    this.field_values,
    fv => fv.name == name && fv.role == 'output'
  );

  if ( fvs.length > 0 ) {
    return fvs[0];
  } else {
    throw "Attempted to access nonexistent output named '" + name + "'";
  }

}

AQ.Operation.record_methods.reload = function() {

  var operation = this;

  return new Promise(function(resolve,reject) {  

    AQ.Operation.find(operation.id).then(
      op => {
        operation.status = op.status;
        operation.job_id = op.job_id;
        operation.recompute_getter('data_associations');
        operation.recompute_getter('job');
        aq.each(operation.field_values, fv => {
          fv.reload();
        });
      }
    );

  });

}

AQ.Operation.getter(AQ.Job,"job");


AQ.Operation.record_methods.instantiate_aux = function(plan,pairs,resolve) {

  var operation = this;

  if ( pairs.length > 0 ) {

    var ofv = pairs[0].ofv,
        sfv = pairs[0].sfv;

    AQ.Sample.find(sfv.child_sample_id).then(linked_sample => {
      operation.routing[ofv.routing] = linked_sample.identifier;
      plan.propagate_down(ofv,linked_sample.identifier);
      ofv.find_items(linked_sample.identifier);
      operation.instantiate_aux(plan,pairs.slice(1),resolve);
      AQ.update();      
    })    

  } else {
    resolve();
  }

}

AQ.Operation.record_methods.instantiate = function(plan,field_value,sid) {

  if ( sid ) {

    var operation = this,
        sample_id = AQ.id_from(sid); 

    return new Promise(function(resolve,reject) {    

      AQ.Sample.where({id: sample_id}, {methods: ["field_values"]}).then(samples => {

        if ( samples.length == 1 ) {

          var sample = samples[0],
              pairs = [];

          aq.each(sample.field_values, sfv => {
            aq.each(operation.field_values, ofv => {
              if ( ofv != field_value && sfv.name == ofv.name && sfv.child_sample_id ) {
                pairs.push({sfv:sfv,ofv: ofv})
              } 
            })
          });

          operation.instantiate_aux(plan,pairs,resolve);

        } 

      });

    });

  } else {
    return new Promise(function(resolve,reject) {});
  }

}

AQ.Operation.record_getters.inputs = function() {

  var op = this;
  delete op.inputs;

  op.inputs = aq.where(op.field_values, fv => fv.role == 'input');

  return op.inputs;

}

AQ.Operation.record_getters.types_and_values = function() {

  var op = this,
      tvs = [];

  aq.each(this.field_values, fv => { if(fv.role == 'input') console.log(fv.name + "(" + fv.rid + "): " + fv.items.length)});

  delete op.types_and_values;

  aq.each(this.field_values, fv => { if(fv.role == 'input') console.log(fv.name + "(" + fv.rid + "): " + fv.items.length)});

  aq.each(op.operation_type.field_types, ft => {
    if ( ft.role == 'input' && ft.ftype == 'sample' ) {
      aq.each(op.field_values, fv => {
        if ( fv.role == 'input' && ft.name == fv.name ) {
          var tv = {type: ft, value: fv};
          tvs.push(tv)
        }
      });
      if ( ft.array ) {
        tvs.push({type: ft, array_add_button: true});
      }
    }
  });

  op.types_and_values = tvs;

  aq.each(this.field_values, fv => { if( fv.role == 'input') console.log(fv.name + "(" + fv.rid + "): " + fv.items.length)});

  return tvs;

}

AQ.Operation.record_getters.last_job = function() {

  var op = this;
  delete op.last_job;

  if ( op.jobs && op.jobs.length > 0 ) {
    op.last_job = op.jobs[op.jobs.length-1];
  } else {
    op.last_job = null;
  }

  return op.last_job;

}

AQ.Operation.record_methods.copy = function() {

  var op = this,
      new_op = AQ.Operation.record({});
  
  new_op.form = { input: {}, output: {} };
  new_op.set_type_with_field_values(
    aq.find(AQ.operation_types,ot => ot.id == op.operation_type_id),
    op.field_values
  );

  return new_op;

}

AQ.Operation.record_methods.field_value_like = function(ofv) {

  var op = this;
  return aq.find(op.field_values, fv => { return fv.name == ofv.name && fv.role == ofv.role });

}

AQ.Operation.record_methods.field_value_with_id = function(id) {

  var op = this;
  return aq.find(op.field_values, fv => { return fv.id == id });

}

AQ.Operation.record_methods.set_status = function(status) {

  var op = this;

  return new Promise(function(resolve,reject) {
    AQ.get("/operations/" + op.id + "/status/" + status).then(response => {
      if ( response.data.status == status ) {
        op.status = status;
        resolve(op);
      }
    });
  });

}


