AQ.OperationType.record_methods.marshall = function() {
  
  var ot = this;

  ot.field_types = aq.collect(ot.field_types, rft => {
    var ft = AQ.FieldType.record(rft);
    ft.allowable_field_types = aq.collect(ft.allowable_field_types, raft => {
      var aft = AQ.AllowableFieldType.record(raft);
      aft.sample_type = AQ.SampleType.record(aft.sample_type);
      aft.object_type = AQ.ObjectType.record(aft.object_type);      
      return aft;
    });
    return ft;
  })

  return ot;

}

function find_aft ( aft_id, ot ) {
  var ids = [];
  var rval = null;
  aq.each(ot.field_types, ft => {
    aq.each(ft.allowable_field_types, aft => {
      ids.push(aft.id);
      if ( aft_id == aft.id ) {
        rval = aft;
      }
    })
  })
  if ( !rval ) {
    console.log("Could not find " + aft_id + " in " + ids.join(","));
  }
  return rval;
}

AQ.Operation.record_methods.marshall = function() {

  // This code is somewhat redundant with AQ.Operation.record_methods.set_type, but different enough
  // that much of that menthod is repeated here. 

  var op = this;

  op.routing = {};
  op.form = { input: {}, output: {} };
  if ( !AQ.id_map ) {
    AQ.id_map = []
  }

  // op.operation_type = AQ.OperationType.record(op.operation_type).marshall();
  var ots = aq.where(AQ.operation_types, ot => ot.deployed && ot.id == op.operation_type_id);

  if ( ots.length != 1 ) {
    alert("Operation " + op.id + " does not have a (deployed) operation type. Skipping.")
    console.log("WARNING: Could not find operation types in AQ. Make sure AQ.operation_types is initialized");
    return null;
  } else {
    op.operation_type = ots[0];
  }

  var input_index = 0, output_index = 0;

  var updated_field_values = [];

  aq.each(op.field_values,(fv) => {

    var ufv = AQ.FieldValue.record(fv);
    AQ.id_map[fv.id] = ufv.rid;

    aq.each(op.operation_type.field_types, ft => {
      if ( ft.role == ufv.role && ft.name == ufv.name ) {
        ufv.field_type = ft;
        ufv.routing = ft.routing;
        ufv.num_wires = 0;
      }
    });

    if ( !ufv.field_type ) {

      alert("Field type for " + ufv.role + " '" + ufv.name + "' of '" + op.operation_type.name + "'  is undefined. " + 
            "This i/o has been dropped. " +
            "The operation type may have changed since this plan was last saved and you probably should not trust this plan.")

    } else {

      if ( ufv.role == 'input' ) { // these indices are for methods that need to know
        ufv.index = input_index++; // which input the fv is (e.g. first, second, etc.)
      }

      if ( ufv.role == 'output' ) {
        ufv.index = output_index++;
      }        

      updated_field_values.push(ufv);

    }

  })

  op.field_values = updated_field_values;

  aq.each(op.field_values, fv => {

    if ( fv.child_sample_id ) {

      op.assign_sample(fv, AQ.to_sample_identifier(fv.child_sample_id));

    } else if ( fv.field_type.routing ) {

      op.routing[fv.field_type.routing] = "";
      
    }

    if ( fv.allowable_field_type_id ) {
      fv.aft = find_aft(fv.allowable_field_type_id, op.operation_type);
      fv.aft_id = fv.allowable_field_type_id;
      op.form[fv.role][fv.name] = { aft_id: fv.allowable_field_type_id, aft: fv.aft }
    }

  });

  op.jobs = aq.collect(op.jobs, job => {
    return AQ.Job.record(job);
  });

  op.width = 160;
  op.height = 30; 

  return op;  

}

AQ.Plan.record_methods.marshall = function() {

  var plan = this;

  var marshalled_operations = [];

  aq.each(plan.operations, op => {
    var op = AQ.Operation.record(op).marshall();
    if ( op ) {
      marshalled_operations.push(op);
    }
  });

  plan.operations = marshalled_operations;

  plan.wires = aq.collect(plan.wires, wire => AQ.Wire.record(wire));

  var skip_wires = [];

  aq.each(plan.wires, w => {
    w.snap = 16;
    aq.each(plan.operations, o => {
      aq.each(o.field_values, fv => {
        if ( w.to_id == fv.id ) {
          w.to = fv;
          w.to_op = o;
          w.to.num_wires++;
        }
        if ( w.from_id == fv.id ) {
          w.from = fv;
          w.from_op = o;
          w.from.num_wires++;
        }
        // fv.recompute_getter("num_wires");
      })
      o.recompute_getter("types_and_values")
      o.recompute_getter('num_inputs');
      o.recompute_getter('num_outputs');       
    });
    if ( !w.to || !w.from ) {
      skip_wires.push(w);
      console.log("WARNING: Skipping wire, probably because operation was deleted.")
    }
  })

  plan.wires = aq.where(plan.wires, w => !skip_wires.includes(w));

  plan.layout = plan.marshall_layout();
  plan.open = true;
  return plan;

}

AQ.Plan.record_methods.marshall_layout = function() {
  
  var plan = this;

  Module.next_module_id = 0; 
  ModuleIO.next_io_id = 0;

  if ( plan.layout ) {

    plan.base_module = new Module().from_object(JSON.parse(plan.layout),plan);
    delete plan.current_module;

  } else {

    delete plan.current_module;
    plan.create_base_module();    

  }

  plan.current_module = plan.base_module;

  plan.base_module.associate_fvs();

}
