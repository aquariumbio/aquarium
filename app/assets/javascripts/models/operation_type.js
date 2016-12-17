
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
      return ots;
    });

}

// RECORD METHODS ==================================================

AQ.OperationType.record_methods.upgrade_field_types = function() {
  this.field_types = aq.collect(this.field_types,(ft) => { 
    var upgraded_ft = new AQ.Record(AQ.FieldType,ft);
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
