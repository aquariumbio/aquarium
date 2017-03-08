
// BASE METHODS ============================================================

AQ.OperationType.compute_categories = function(ots) {

  ots.categories = aq.uniq(aq.collect(ots,function(ot) {
    return ot.category;
  }));

}

AQ.OperationType.all = function() {

  return this.super('all').then(
    (ots) => {
      this.compute_categories(ots);
      return ots;
    });

}

AQ.OperationType.all_with_content = function() {

  return this.array_query(
      'all', [], 
      { methods: [ 'field_types', 'cost_model', 'documentation' ] }
    ).then((ots) => {
      aq.each(ots,function(ot) { ot.upgrade_field_types(); })
      this.compute_categories(ots);
      return ots;
    });

}

// RECORD METHODS ==================================================

AQ.OperationType.record_methods.upgrade_field_types = function() {
  this.field_types = aq.collect(this.field_types,(ft) => { 
    var upgraded_ft = AQ.FieldType.record(ft);
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

AQ.OperationType.record_getters.numbers = function() {

  var ot = this;

  delete ot.numbers;
  ot.numbers = {};
  
  AQ.post("/operation_types/numbers",ot).then((response) => {
    ot.numbers = response.data;
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

