AQ.Plan.record_methods.submit = function() {

  var plan = this;

  return new Promise(function(resolve,reject) {
    AQ.post('/launcher/submit',plan).then(
      (response) => {
        resolve(AQ.Plan.record(response.data));
      }, (response) => {
        reject(response.data.errors);
      }
    );
  });

}

AQ.Plan.record_methods.link_operation_types = function(operation_types) {

  aq.each(this.operations,(operation) => {
    operation.operation_type = aq.find(operation_types,(ot) => { 
      return ot.id == operation.operation_type.id 
    } );
  });

}

AQ.Plan.list = function(user) {

  return new Promise(function(resolve,reject) {
    AQ.get('/launcher/plans').then(
      (response) => {
        resolve(aq.collect(response.data.plans,(p) => { 
          var plan = AQ.Plan.record(p);
          plan.operations = aq.collect(plan.operations,(op) => {
            var operation = AQ.Operation.record(op);
            operation.field_values = aq.collect(
              aq.where(response.data.field_values, (fv) => {
                return fv.parent_id == operation.id;
              }), (fv) => { return AQ.FieldValue.record(fv); })
            return operation;
          });
          return plan;
        }));
      }, (response) => {
        reject(response.data.errors);
      }
    );
  });

}
