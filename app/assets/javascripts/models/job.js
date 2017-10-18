AQ.Job.record_getters.url = function() {
  delete this.url;
  return this.url = "<a href='/jobs/" + this.id + "'>" + this.id + "</a>";
}

AQ.Job.getter(AQ.User,"user");

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
  AQ.JobAssociation.where({job_id: job.id} ).then(jas => {
    let ids = aq.collect(jas, ja => ja.operation_id);
    AQ.Operation.where({id: ids}, { include: "operation_type" }).then(ops => {
      job.operations = ops;
      console.log(job.operations)
      AQ.update();
    })
  })
}
