AQ.Job.record_getters.url = function() {
  return "<a href='/jobs/" + this.id + "'>" + this.id + "</a>";
}

AQ.Job.getter(AQ.User,"user");