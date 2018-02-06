AQ.Job.record_methods.upgrade = function() {

  var job = this;

  try {
    job.state = JSON.parse(job.state);
    job.state.index = job.backtrace.length - 1;
    // if ( job.state.index > 0 && job.backtrace[job.state.index].type == 'aborted' ) {
    //   job.state.index -= 1;
    // }
  } catch(e) {
  }

  return this;
}

AQ.Job.record_getters.type = function() {
  let job = this;
  if ( job.operations && job.operations.length > 0 ) {
    if ( job.operations[0].operation_type ) {
      return job.operations[0].operation_type.name;
    }
  }
  return "Unknown";
}

AQ.Job.record_getters.url = function() {
  delete this.url;
  return this.url = "<a href='/jobs/" + this.id + "'>" + this.id + "</a>";
}

AQ.Job.getter(AQ.User,"user");

AQ.Job.record_getters.started = function() {
  return this.pc != -1;
}

AQ.Job.record_getters.status = function() {

  delete this.status;

  if ( this.pc == -2 ) {
    this.status = "done";
  } else if ( this.pc == -1 ) {
    this.status = "pending";
  } else {
    this.status = "running";
  }

  return this.status;

}

AQ.Job.record_getters.operations = function() {
  let job = this;
  delete job.operations;
  AQ.JobAssociation.where({job_id: job.id}).then(jas => {
    let ids = aq.collect(jas, ja => ja.operation_id);
    AQ.Operation.where({id: ids}, { include: "operation_type", methods: [ "data_associations"] }).then(ops => {
      aq.each(ops,op => {
        op.data_associations = aq.collect(
          op.data_associations, 
          da => { 
            AQ.DataAssociation.record(da)
            if ( da.upload_id ) {
              da.upload = AQ.Upload.record(da.upload);
            }
            return da;
          }
        );
      });
      job.operations = ops;
      AQ.update();
    })
  })
}

AQ.Job.record_getters.uploads = function() {

  let job = this;
  delete job.uploads;

  AQ.Upload.where({job_id: job.id}).then(uploads => {
    job.uploads = uploads;
    AQ.update();
  });

}

AQ.Job.record_getters.backtrace = function() {

  var job = this;
  delete job.backtrace;
  job.backtrace = new Backtrace()
  job.backtrace.init(job.state);
  return job.backtrace;

}

AQ.Job.record_getters.is_complete = function() {
  var job = this;
  return job.backtrace && job.backtrace.complete;
}

AQ.Job.record_methods.advance = function() {

  var job = this;

  job.sending = true;

  return new Promise(function(resolve,reject) {

    AQ.http.post("/krill/next?command=next&job="+job.id,job.backtrace.last_response).then(

      response => {        

        let result = response.data.result;

        job.state = response.data.state;
        job.recompute_getter("backtrace");
        job.state.index = job.backtrace.length - 1;
        if ( job.backtrace[job.state.index].type == 'aborted' ) {
          job.state.index -= 1;
        }

        job.sending = false;

        resolve();

      }, response => {

        job.sending = false;        

        reject(respose.data);

      });

  });

}

AQ.Job.record_methods.abort = function() {

  let job = this;

  return new Promise(function(resolve,reject) {

    AQ.http.get("/krill/abort?job="+job.id).then(response => {
      resolve(response.data.result);
    });

  });  

}

AQ.Job.active_jobs = function() {

  return new Promise(function(resolve,reject) {

    AQ.http.get("/krill/jobs").then(response => {
      resolve(response.data.jobs);
    });

  });

}

