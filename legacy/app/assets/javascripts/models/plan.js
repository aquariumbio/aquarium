AQ.Plan.new_plan = function(name) {
  var plan = AQ.Plan.record({
    operations: [],
    wires: [],
    status: "planning",
    name: name
  });

  plan.create_base_module();
  return plan;
};

AQ.Plan.record_methods.add_operation = function(operation) {
  let plan = this;
  plan.operations.push(operation);
  operation.plan = plan;
  return plan;
};

AQ.Plan.record_methods.reload = function() {
  var plan = this;
  plan.recompute_getter("data_associations");

  AQ.PlanAssociation.where({ plan_id: plan.id }).then(pas => {
    AQ.Operation.where(
      { id: aq.collect(pas, pa => pa.operation_id) },
      { methods: ["field_values", "operation_type", "jobs"] }
    ).then(ops => {
      plan.operations = ops;
      plan.recompute_getter("costs");
      aq.each(plan.operations, op => {
        op.field_values = aq.collect(op.field_values, fv => {
          return AQ.FieldValue.record(fv);
        });
        op.jobs = aq.collect(op.jobs, job => {
          return AQ.Job.record(job);
        });
        op.reload().then(op => {
          op.open = false;
          AQ.update();
        });
      });
      plan.recompute_getter("deletable");
      plan.recompute_getter("state");
      plan.recompute_getter("cost_so_far");
    });
  });
};

AQ.Plan.record_methods.save = function(user) {
  var plan = this,
    before = plan,
    user_query = user ? "?user_id=" + user.id : "";

  plan.saving = true;

  if (plan.id) {
    return new Promise((resolve, reject) => {
      AQ.put("/plans/" + plan.id + ".json" + user_query, plan.serialize())
        .then(response => {
          delete plan.saving;
          var p = AQ.Plan.record(response.data).marshall();
          AQ.Test.plan_diff(before, p);
          resolve(p);
        })
        .catch(response => {
          console.log(response);
          plan.errors = ["PUT error"];
        });
    });
  } else {
    return new Promise((resolve, reject) => {
      AQ.post("/plans.json" + user_query, plan.serialize())
        .then(response => {
          delete plan.saving;
          var p = AQ.Plan.record(response.data).marshall();
          AQ.Test.plan_diff(before, p);
          resolve(p);
        })
        .catch(response => {
          console.log(response.data.errors);
          plan.errors = response.data.errors;
        });
    });
  }
};

AQ.Plan.load = function(id) {
  let start_time = new Date();
  return new Promise((resolve, reject) => {
    AQ.get("/plans/" + id + ".json")
      .then(response => {
        try {
          resolve(
            AQ.Plan.record(response.data)
              .marshall()
              .assign_items()
          );
          console.log(`Plan ${id} loaded in ${new Date() - start_time} ms`);
        } catch (e) {
          reject(e);
        }
      })
      .catch(response => reject(response.data));
  });
};

AQ.Plan.record_getters.unassigned_inputs = function() {
  let plan = this,
    fvs = [];

  aq.each(plan.operations, op => {
    if (op.status == "planning") {
      aq.each(op.inputs, fv => {
        if (!fv.child_item_id && fv.num_wires == 0) {
          fvs.push(fv);
        }
      });
    }
  });

  return fvs;
};

AQ.Plan.record_methods.assign_items = function() {
  let plan = this;

  aq.each(plan.unassigned_inputs, input => {
    input.find_items().then(() => AQ.update());
  });

  return plan;
};

AQ.Plan.record_methods.submit = function(user) {
  var original_plan = this,
    plan = this.serialize(),
    user_query = user ? "&user_id=" + user.id : "",
    budget_query = "?budget_id=" + this.uba.budget_id;

  return AQ.get(
    "/plans/start/" + plan.id + budget_query + user_query,
    plan
  ).then(response => original_plan); // caller should reload the plan if needed to get updated operation status
};

AQ.Plan.record_methods.cancel = function(msg) {
  var plan = this;

  return new Promise(function(resolve, reject) {
    AQ.get("/plans/cancel/" + plan.id + "/" + msg).then(
      response => {
        plan.reload();
        resolve(response.data);
        plan.recompute_getter("deletable");
        plan.recompute_getter("state");
      },
      response => {
        reject(response.data.errors);
      }
    );
  });
};

AQ.Plan.record_methods.link_operation_types = function(operation_types) {
  aq.each(this.operations, operation => {
    operation.operation_type = aq.find(operation_types, ot => {
      return ot.id == operation.operation_type.id;
    });
  });
};

AQ.Plan.list = function(offset, user, folder, plan_id) {
  var user_query = user ? "&user_id=" + user.id : "",
    plan_query = plan_id ? "&plan_id=" + plan_id : "",
    folder_query = folder ? "&folder=" + folder : "";

  return new Promise(function(resolve, reject) {
    AQ.get(
      "/launcher/plans?offset=" +
        offset +
        user_query +
        plan_query +
        folder_query
    ).then(
      response => {
        AQ.Plan.num_plans = response.data.num_plans;
        resolve(
          aq.collect(response.data.plans, p => {
            var plan = AQ.Plan.record(p);
            plan.operations = aq.collect(plan.operations, op => {
              var operation = AQ.Operation.record(op);
              operation.mode = "io"; // This is for the launcher UI.
              operation.field_values = aq.collect(
                aq.where(response.data.field_values, fv => {
                  return fv.parent_id == operation.id;
                }),
                fv => {
                  return AQ.FieldValue.record(fv);
                }
              );
              operation.jobs = aq.collect(op.jobs, job => {
                return AQ.Job.record(job);
              });
              return operation;
            });
            return plan;
          })
        );
      },
      response => {
        reject(response.data.errors);
      }
    );
  });
};

AQ.Plan.record_methods.wire = function(from_op, from, to_op, to) {
  var plan = this;

  if (!plan.wires) {
    plan.wires = [];
  }

  var wire = AQ.Wire.make({
    from_op: from_op,
    from: from,
    to_op: to_op,
    to: to
  });

  plan.wires.push(wire);

  return wire;
};

AQ.Plan.record_methods.unwire = function(op) {
  var plan = this;

  aq.each(plan.wires, wire => {
    if (wire.from_op == op || wire.to_op == op) {
      wire.disconnect();
      aq.remove(plan.wires, wire);
    }
  });
};

AQ.Plan.record_methods.remove_wires_to = function(op, fv) {
  var plan = this;

  aq.each(plan.wires, wire => {
    if (wire.to_op == op && wire.to == fv) {
      wire.disconnect();
      aq.remove(plan.wires, wire);
    }
  });

  return plan;
};

AQ.Plan.record_methods.remove_wires_from = function(op, fv) {
  var plan = this;

  aq.each(plan.wires, wire => {
    if (wire.from_op == op && wire.from == fv) {
      wire.disconnect();
      aq.remove(plan.wires, wire);
    }
  });

  return plan;
};

AQ.Plan.record_methods.is_wired = function(op, fv) {
  var plan = this,
    found = false;

  aq.each(plan.wires, wire => {
    if (wire.to_op == op && wire.to == fv) {
      found = true;
    }
  });

  return found;
};

AQ.Plan.record_methods.siblings = function(fv) {
  var plan = this,
    from_module_io,
    sibs = [];

  aq.each(plan.base_module.all_wires, wire => {
    if (wire.to == fv && wire.from_module) {
      from_module_io = wire.from;
    }
  });

  aq.each(plan.base_module.all_wires, wire => {
    if (
      wire.to != fv &&
      wire.to.record_type == "FieldValue" &&
      wire.from == from_module_io
    ) {
      sibs.push({ fv: wire.to, op: wire.to_op });
    }
  });

  return sibs;
};

AQ.Plan.record_methods.add_wire_from = function(fv, op, pred) {
  // pred is expected to be of the form { operation_type: ___, output: ___}

  let plan = this,
    preop = AQ.Operation.new_operation(
      pred.operation_type,
      plan.current_module.id,
      op.x,
      op.y + 4 * AQ.snap
    ),
    preop_output = preop.output(pred.output.name);

  let num_wires_into = aq.where(op.plan.wires, wire => wire.to_op == op).length;

  plan.add_operation(preop);
  preop.x += (preop.width + AQ.snap) * num_wires_into;

  plan.remove_wires_to(op, fv);

  let wire = plan.wire(preop, preop_output, op, fv),
    sid = null;

  if (fv.field_type.array) {
    sid = fv.sample_identifier;
  } else {
    sid = op.routing[fv.routing];
  }

  if (sid) {
    return AQ.Sample.find_by_identifier(sid)
      .then(sample => plan.assign(fv, sample))
      .then(plan => plan.choose_items());
  } else {
    return Promise.resolve(plan);
  }
};

AQ.Plan.record_methods.add_wire_to = function(fv, op, suc) {
  let plan = this,
    postop = AQ.Operation.new_operation(
      suc.operation_type,
      plan.current_module.id,
      op.x,
      op.y - 4 * AQ.snap
    ),
    postop_input = postop.input(suc.input.name);

  let num_wires_outof = aq.where(op.plan.wires, wire => wire.from_op == op)
    .length;

  plan.add_operation(postop);
  postop.x += (postop.width + AQ.snap) * num_wires_outof;

  plan.remove_wires_from(op, fv);

  let wire = plan.wire(op, fv, postop, postop_input);

  if (fv.field_type.array) {
    sid = fv.sample_identifier;
  } else {
    sid = op.routing[fv.routing];
  }

  if (op.status == "planning" && sid) {
    return AQ.Sample.find_by_identifier(sid)
      .then(sample => plan.assign(fv, sample))
      .then(plan => plan.choose_items());
  } else {
    return Promise.resolve(plan);
  }

  return Promise.resolve(plan);
};

AQ.Plan.record_methods.remove_wire = function(wire) {
  var plan = this;
  wire.disconnect();
  aq.remove(plan.wires, wire);
};

AQ.Plan.record_methods.debug = function() {
  var plan = this;
  plan.debugging = true;

  return AQ.get("/plans/" + plan.id + "/debug")
    .then(response => {
      plan.reload();
      plan.debugging = false;
      plan.recompute_getter("state");
    })
    .then(() => plan);
};

AQ.Plan.record_methods.relaunch = function() {
  var plan = this;

  return new Promise(function(resolve, reject) {
    AQ.get("/launcher/" + plan.id + "/relaunch").then(
      response => {
        var p = AQ.Plan.record(response.data.plan).marshall();
        resolve(p, response.data.issues);
      },
      response => reject(null, response.data.issues)
    );
  });
};

AQ.Plan.getter(AQ.Budget, "budget");

AQ.Plan.record_methods.wire_aux = function(op, wires, operations) {
  var plan = this;

  aq.each(wires, w => {
    var fv = op.field_value_with_id(w.to_id);
    if (fv) {
      aq.each(operations, from_op => {
        var from_fv = from_op.field_value_with_id(w.from_id);
        if (from_fv) {
          var new_from_op = from_op.copy(),
            new_from_fv = new_from_op.field_value_like(from_fv);
          plan
            .wire(new_from_op, new_from_fv, op, fv)
            .wire_aux(new_from_op, wires, operations);
        }
      });
    }
  });
};

AQ.Plan.record_methods.copy = function() {
  var old_plan = this;

  return new Promise(function(resolve, reject) {
    AQ.Plan.where({ id: old_plan.id }, { methods: ["wires", "goals"] }).then(
      plans => {
        var plan = AQ.Plan.record(plans[0]),
          new_plan = AQ.Plan.record({});

        new_plan.operations = aq.collect(plan.goals, g => {
          return AQ.Operation.record(g).copy();
        });

        aq.each(new_plan.operations, op => {
          new_plan.wire_aux(op, plans[0].wires, old_plan.operations);
        });

        resolve(new_plan);
      }
    );
  });
};

AQ.Plan.record_getters.deletable = function() {
  var plan = this;

  delete plan.deletable;
  plan.deletable = true;

  aq.each(plan.operations, op => {
    if (op.status != "error" || op.jobs === undefined || op.jobs.length > 0) {
      plan.deletable = false;
    }
  });

  return plan.deletable;
};

AQ.Plan.record_methods.valid = function() {
  var plan = this,
    v = plan.operations.length > 0;

  aq.each(plan.operations, op => {
    if (op.status != "error") {
      aq.each(op.field_values, fv => {
        v = v && fv.valid();
      });
    }
  });

  aq.each(plan.wires, wire => {
    v = v && wire.consistent();
  });

  return v;
};

AQ.Plan.record_methods.destroy = function() {
  var plan = this;

  return new Promise(function(resolve, reject) {
    AQ.http.delete("/plans/" + plan.id);
    resolve();
  });
};

AQ.Plan.move = function(plans, folder) {
  var pids = aq.collect(plans, plan => plan.id);

  return new Promise(function(resolve, reject) {
    AQ.http
      .put("/plans/move", { pids: pids, folder: folder })
      .then(() => {
        aq.each(plans, plan => {
          plan.folder = folder;
        });
        resolve();
      })
      .catch(reject);
  });
};

AQ.Plan.get_folders = function(user_id = null) {
  return new Promise(function(resolve, reject) {
    var user_query = user_id ? "?user_id=" + user_id : "";

    AQ.get("/plans/folders" + user_query)
      .then(response => {
        resolve(response.data.sort());
      })
      .catch(reject);
  });
};

AQ.Plan.record_getters.state = function() {
  var plan = this;
  delete plan.state;
  plan.state = "Pending";

  // if all ops are done, the done
  var not_done = aq.where(plan.operations, op => op.status != "done");
  var errors = aq.where(plan.operations, op => op.status == "error");
  var delays = aq.where(plan.operations, op => op.status == "delayed");

  if (not_done.length == 0) {
    plan.state = "Done";
  } else if (errors.length > 0) {
    plan.state = "Error";
  } else if (delays.length > 0) {
    plan.state = "Delayed";
  }

  return plan.state;
};

AQ.Plan.record_methods.find_items = function() {
  var plan = this;

  aq.each(plan.operations, op => {
    aq.each(op.field_values, fv => {
      fv.recompute_getter("items");
    });
  });
};

AQ.Plan.record_methods.check_for_items = function() {
  var plan = this;

  aq.each(plan.operations, op => {
    aq.each(op.field_values, fv => {
      if (fv.items.length == 0) {
        fv.recompute_getter("items");
      }
    });
  });
};

AQ.Plan.record_methods.replan = function() {
  var plan = this;

  return new Promise(function(resolve, reject) {
    AQ.get("/plans/replan/" + plan.id)
      .then(response => {
        resolve(response.data);
      })
      .catch(reject);
  });
};

AQ.Plan.record_methods.find_by_rid = function(rid) {
  var plan = this,
    object = null;

  aq.each(plan.operations, op => {
    if (op.rid == rid) {
      object = op;
    } else {
      aq.each(op.field_values, fv => {
        if (fv.rid == rid) {
          object = fv;
        }
      });
    }
  });

  return object;
};

AQ.Plan.record_methods.find_by_id = function(id) {
  var plan = this,
    object = null;

  aq.each(plan.operations, op => {
    if (op.id == id) {
      object = op;
    } else {
      aq.each(op.field_values, fv => {
        if (fv.id == id) {
          object = fv;
        }
      });
    }
  });

  return object;
};

AQ.Plan.record_methods.add_wire = function(from, from_op, to, to_op) {
  if (from.role == "output" && from.field_type.can_produce(to)) {
    if (!this.reachable(to, from)) {
      this.wires.push(
        AQ.Wire.make({
          from_op: from_op,
          from: from,
          to_op: to_op,
          to: to,
          snap: AQ.snap
        })
      );
    } else {
      alert("Cycle detected. Cannot create wire.");
    }
  } else if (to.role == "output" && to.field_type.can_produce(from)) {
    // #TODO: determine whether this is legit. Seems wrong.
    if (!this.reachable(from, to)) {
      this.wires.push(
        AQ.Wire.make({
          to_op: from_op,
          to: from,
          from_op: to_op,
          from: to,
          snap: AQ.snap
        })
      );
    } else {
      alert("Cycle detected. Cannot create wire.");
    }
  }
};

AQ.Plan.record_methods.num_plan_wires_into = function(io) {
  var plan = this;
  return aq.where(plan.wires, w => w.to.rid == io.rid).length;
};

AQ.Plan.record_methods.num_module_wires_into = function(io) {
  return this.base_module.num_wires_into(io);
};

AQ.Plan.record_methods.num_wires_into = function(io) {
  var plan = this;
  return plan.num_plan_wires_into(io) + plan.num_module_wires_into(io);
};

AQ.Plan.record_methods.recount_fv_wires = function() {
  var plan = this;

  aq.each(plan.operations, op => {
    aq.each(op.field_values, fv => {
      fv.num_wires = 0;
    });
  });

  aq.each(plan.wires, w => {
    w.from.num_wires++;
    w.to.num_wires++;
  });
};

AQ.Plan.record_methods.create_text_box = function() {
  let plan = this;
  return plan.current_module.create_text_box();
};

AQ.Plan.record_methods.parent_operation = function(field_value) {
  let plan = this;
  for (var i = 0; i < plan.operations.length; i++) {
    for (var j = 0; j < plan.operations[i].field_values.length; j++) {
      if (plan.operations[i].field_values[j] == field_value) {
        return plan.operations[i];
      }
    }
  }
  return null;
};

AQ.Plan.record_getters.leaves = function() {
  let plan = this;
  plan.mark_leaves();
  return aq.where(plan.field_values(), fv => fv.leaf);
};

AQ.Plan.record_methods.choose_items = function() {
  let plan = this;

  return Promise.all(
    aq.collect(plan.leaves, fv => fv.find_items(fv.child_sample_id))
  ).then(() => {
    return plan;
  });
};

AQ.Plan.record_methods.show_assignments = function() {
  var plan = this;

  plan.field_values().forEach(fv => {
    let str = fv.name + ": " + fv.sid;
    if (fv.child_item_id) {
      str += ", item id = " + fv.child_item_id;
      if (typeof fv.row == "number" && typeof fv.column == "number") {
        str += `[${fv.row}, ${fv.column}]`;
      }
    }
    console.log(str);
  });

  return plan;
};

AQ.Plan.record_methods.operation = function(type_name, index = 0) {
  let plan = this,
    operations = aq.where(
      plan.operations,
      op => op.operation_type.name == type_name
    );

  if (operations.length > index) {
    return operations[index];
  } else {
    raise(
      `Could not find operation ${index} of type '${type_name}' in plan '${plan.name}'`
    );
  }
};

/* Returns true if this plan has active operations and new, inactive, operations.
 */
AQ.Plan.record_getters.has_new_ops = function() {
  let active = aq.where(this.operations, op => op.status != "planning").length,
    inactive = aq.where(this.operations, op => op.status == "planning").length;

  return active > 0 && inactive > 0;
};

AQ.Plan.record_getters.saved = function() {
  var plan = this;

  if (!plan.id) {
    return false;
  } else {
    for (var i = 0; i < plan.operations.length; i++) {
      if (!plan.operations[i].id) {
        return false;
      }
    }
  }

  return true;
};

AQ.Plan.record_methods.step_operations = function() {
  console.log("AQ.Plan.step()");
  return AQ.get("/operations/step?plan_id=" + this.id);
};

AQ.Plan.record_getters.link = function() {
  let plan = this;
  return window.location.href.split("#")[0] + "?plan_id=" + plan.id;
};
