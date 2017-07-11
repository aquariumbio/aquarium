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