AQ.Operation.getter(AQ.User,"user");

AQ.Operation.new_operation = function(operation_type, parent_module_id=0, x=100, y=100) {

  var op = AQ.Operation.record({
    x: x,
    y: y,
    width: 160, 
    height: 30,
    routing: {},
    form: { input: {}, output: {} },
    parent_id: parent_module_id,
    status: "planning"
  });
  op.set_type(operation_type);

  return op;

}

AQ.Operation.record_methods.upgrade = function() {

  let operation = this;
  operation.show_uploads = false;

  return this;

}

AQ.Operation.record_getters.plans = function() {
  let op = this;
  delete op.plans;
  AQ.PlanAssociation.where({operation_id: op.id}, { include: "plan"}).then(pas => {
    op.plans = aq.collect(pas, pa => AQ.Plan.record(pa.plan));
  })
  return [];
}

AQ.Operation.record_getters.alt_field_values = function() {
  // Note this method should replace field_values, but can't because of some
  // backward compatability issues in the planner.
  let op = this;
  delete op.alt_field_values;
  AQ.FieldValue.where({parent_id: op.id, parent_class: "Operation"}).then(fvs => {
    op.alt_field_values = aq.collect(fvs, fv => AQ.FieldValue.record(fv));
    AQ.update();
  })
  return [];
}

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

  let  op = this;

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

      if ( op.plan ) {

        // try to assign a sample by looking at equivalent field values
        let assigned_fvs = aq.where(
          AQ.Plan.equivalence_class_of(op.plan.classes(), fv), 
          other_fv => other_fv.child_sample_id );

        if ( assigned_fvs.length > 0 ) {
          op.assign_sample(fv,assigned_fvs[0].sid);
        }

      }

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

  fv.child_sample_id = AQ.id_from(sid);
  fv.sid = sid;

  if ( fv.field_type && !fv.field_type.array ) {
    op.routing[fv.routing] = sid;          
  }

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

AQ.Operation.record_methods.io = function(name,role,index=0) {

  var fvs = aq.where(
    this.field_values,
    fv => fv.name == name && fv.role == role
  );

  if ( fvs.length > index ) {
    return fvs[index];
  } else {
    throw "Attempted to access nonexistent " + role + " named '" + name + "'" + " indexed by " + index;
  }

}

AQ.Operation.record_methods.output = function(name, index=0) { return this.io(name, 'output', index); }
AQ.Operation.record_methods.input = function(name, index=0) { return this.io(name, 'input', index);  }

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

AQ.Operation.record_getters.inputs = function() {

  var op = this;
  delete op.inputs;

  op.inputs = aq.where(op.field_values, fv => fv.role == 'input');

  return op.inputs;

}

AQ.Operation.record_getters.outputs = function() {

  var op = this;
  delete op.outputs;

  op.outputs = aq.where(op.field_values, fv => fv.role == 'output');

  return op.outputs;

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

AQ.Operation.record_getters.jobs = function() {

  let op = this;
  delete op.jobs;

  AQ.JobAssociation.where({ operation_id: op.id }, { include: "job" }).then(jas => {
    op.jobs = aq.collect(jas, ja => AQ.Job.record(ja.job));
    AQ.update();
  })

  return op.jobs;

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

/*
 * If the operation is a leaf or if its inputs are ready and its precondition is true,
 * then set the operation to 'pending' else set it to 'waiting'.
 */
AQ.Operation.record_methods.retry = function() {

  let op = this;

  return new Promise(function(resolve, reject) {
    AQ.get(`/operations/${op.id}/retry`)
      .then(response => {
        console.log(response)
        if ( response.data.status ) {
          op.status = response.data.status;
          resolve(op);
        }
      })
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

AQ.Operation.record_methods.process_upload_complete = function() {
  let operation = this;
  try {
    console.log("trying");
    update_job_uploads();
  } catch(e) {
    console.log("failed", e)
  }
}
