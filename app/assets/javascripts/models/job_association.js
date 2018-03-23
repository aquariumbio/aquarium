AQ.JobAssociation.record_methods.upgrade = function() {

  var ja = this;

  if ( ja.job ) {
    ja.job = AQ.Job.record(ja.job);
  }

  if ( ja.operation ) {
    ja.operation = AQ.Job.record(ja.operation);
  }  

  return ja;

}