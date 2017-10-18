AQ.Operation.record_methods.set_type = function(operation_type) {

  var op = this;

  op.operation_type_id = operation_type.id;
  op.operation_type = operation_type;
  op.field_values = [];

  var input_index = 0, output_index = 0;

  aq.each(operation_type.field_types, ft => {

    var fv = AQ.FieldValue.record({ 
      name: ft.name, 
      role: ft.role, 
      routing: ft.routing,
      field_type: ft
    });

    if ( fv.role == 'input' ) { // these indices are for methods that need to know
      fv.index = input_index++; // which input the fv is (e.g. first, second, etc.)
    }

    if ( fv.role == 'output' ) {
      fv.index = output_index++;
    }    

    op.field_values.push(fv);

    if ( ft.allowable_field_types.length > 0 ) {
      op.set_aft(ft,ft.allowable_field_types[0])
    }

    fv.items = [];

  });

  return this;

}

AQ.Operation.record_methods.inputs = function() {
  return aq.where(this.field_values, fv => fv.role == 'input');
}

AQ.Operation.record_methods.outputs = function() {
  return aq.where(this.field_values, fv => fv.role == 'output');
}

AQ.Operation.record_getters.num_inputs = function() {
  var op = this;
  delete op.num_inputs;
  op.num_inputs = aq.sum(op.field_values, fv => fv.role == 'input' ? 1 : 0 );
  return op.num_inputs;
}

AQ.Operation.record_getters.num_outputs = function() {
  var op = this;
  delete op.num_outputs;
  op.num_outputs = aq.sum(op.field_values, fv => fv.role == 'output' ? 1 : 0 );
  return op.num_outputs;
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
          // child_sample: old_fv.child_sample
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
      fv.allowable_field_type_id = aft.id;
      fv.field_type = ft;
      fv.recompute_getter('predecessors');
      fv.recompute_getter('successors');
      delete fv.items;
      delete fv.sid;
      delete fv.sample_identifier;
      delete fv.child_sample_id;
      delete fv.child_item_id;
    }
  });
}

AQ.Operation.record_methods.clear = function() {
  delete this.operation_type_id;
  delete this.operation_type;
  delete this.allowable_field_types;
  return this;
}

AQ.Operation.record_methods.assign_sample = function(fv,sid) {

  var op = this;

  op.routing[fv.routing] = sid;            // set the sid for the source op's routing symbol
  fv.child_sample_id = AQ.id_from(sid);
  fv.sid = sid;

  if ( fv.field_type && fv.field_type.array ) {
    fv.sample_identifier = sid;
  } 

  op.recompute_getter("types_and_values")  

  return op;

}

AQ.Operation.record_methods.array_remove = function(fv) {

  var j = 0;

  while ( this.field_values[j] != fv ) {
    j++;
  }
  fv.deleted = true;
  
  this.field_values.splice(j,1);
  this.recompute_getter('types_and_values');
  this.recompute_getter('num_inputs');
  this.recompute_getter('num_outputs');  

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
  this.recompute_getter('num_inputs');
  this.recompute_getter('num_outputs');  

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

AQ.Operation.record_methods.io = function(name,role) {

  var fvs = aq.where(
    this.field_values,
    fv => fv.name == name && fv.role == role
  );

  if ( fvs.length > 0 ) {
    return fvs[0];
  } else {
    throw "Attempted to access nonexistent " + role + " named '" + name + "'";
  }

}

AQ.Operation.record_methods.output = function(name) { return this.io(name, 'output'); }
AQ.Operation.record_methods.input = function(name) { return this.io(name, 'input');  }

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
      operation.assign_sample(ofv,linked_sample.identifier );
      plan.propagate_down(ofv,linked_sample.identifier);

      ofv.clear_item();
      ofv.find_items(linked_sample.identifier).then(items => AQ.update());

      operation.instantiate_aux(plan,pairs.slice(1),resolve);
      AQ.update();

    })    

  } else {
    resolve();
  }

}

AQ.Operation.record_methods.instantiate = function(plan,field_value,sid) { // instantiate this operation's field values using the sid
                                                                           // assuming it is being assigned to the argument field_value
                                                                           // will need to look at the field_value's routing information
                                                                           // as well as its sample definition
  var operation = this,
      sample_id = AQ.id_from(sid);

  aq.each(operation.field_values, fv => {
    if ( !fv.field_type.array && fv.routing == field_value.routing ) {
      operation.assign_sample(fv, sid);
    }
  })

  if ( sid ) {
    
    // Find items associated with samples
    aq.each(operation.field_values, fv => {
      if ( !fv.field_type.array && fv.routing == field_value.routing ) {
        fv.clear_item().find_items(sid);
      }
    })

    // Next, find fvs that can be assigned from sample information (using linked samples)
    return new Promise(function(resolve,reject) {    

      AQ.Sample.where({id: sample_id}, {methods: ["field_values"]}).then(samples => {  // get the sample corresponding to sid

        if ( samples.length == 1 ) { // there should only be one

          var sample = samples[0], 
              pairs = [];            // pairs will hold a list of sample field values (sfv) and operation field_values (ofv) that should be identified

          aq.each(sample.field_values, sfv => {
            aq.each(operation.field_values, ofv => {
              if ( ofv != field_value && sfv.name == ofv.name && sfv.child_sample_id ) {
                pairs.push({sfv:sfv,ofv: ofv})
              } 
            })
          });

          operation.instantiate_aux(plan,pairs,resolve); // once all pairs are found, actually do the instantiate in instantiate_aux

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

  delete op.types_and_values;

  var input_index = 0,
      output_index = 0;

  aq.each(['input', 'output'], role => {
    aq.each(op.operation_type.field_types, ft => {
      if ( ft.role == role ) {
        aq.each(op.field_values, fv => {
          if ( fv.role == ft.role && ft.name == fv.name ) {
            var tv = {type: ft, value: fv, role: role};
            tvs.push(tv);
            if ( role == 'input' ) {
              fv.index = input_index++;
            } else {
              fv.index = output_index++;
            }
          }
        });
        if ( ft.array ) {
          tvs.push({type: ft, value: {}, array_add_button: true, role: ft.role});
        }
      } 
    });
  });

  op.types_and_values = tvs;

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

AQ.Operation.record_methods.input_pin_x = function(fv) {
  return this.x + this.width/2 + (fv.index - this.num_inputs/2.0 + 0.5)*AQ.snap;
}

AQ.Operation.record_methods.input_pin_y = function(fv) {
  return this.y + this.height;
}


AQ.Operation.record_methods.output_pin_x = function(fv) {
  return this.x + this.width/2 + (fv.index - this.num_outputs/2.0 + 0.5)*AQ.snap;  
}

AQ.Operation.record_methods.output_pin_y = function(fv) {
  return this.y;
}

AQ.Operation.record_methods.role = function(fv) {
  return fv.role;
}

AQ.Operation.step_all = function() {

  return AQ.get("/operations/step");

}

AQ.Operation.manager_list = function(criteria,options) {
        // AQ.Operation.where(criteria, {
        //   methods: ['user', 'field_values', 'plans', 'jobs']
        // }, options).

  return new Promise(function(resolve,reject) {

    AQ.post("/operations/manager_list", { criteria: criteria, options: options }).then(response => {
      let ops = aq.collect(response.data, op => AQ.Operation.record(op));
      aq.each(ops, op => { 
        op.job = AQ.Job.record(op.job);
        op.user = AQ.User.record(op.user);
        op.plans = aq.collect(op.plans, plan => AQ.Plan.record(plan));
        op.field_values = aq.collect(op.field_values, raw_fv => {
          fv = AQ.FieldValue.record(raw_fv)
          if ( fv.item ) { 
            fv.item = AQ.Item.record(fv.item); 
            fv.item.object_type = AQ.ObjectType.record(fv.item.object_type);
          }
          if ( fv.sample ) { fv.sample = AQ.Sample.record(fv.sample); }
          return fv;
        });
        op.data_associations = aq.collect(op.data_associations, da => AQ.DataAssociation.record(da))
      });
      resolve(ops)
    })

  });      

}
