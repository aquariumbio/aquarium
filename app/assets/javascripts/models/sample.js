AQ.Sample.record_getters.identifier = function() {
  var s = this;
  delete s.identifier;
  s.identifier = s.id + ": " + s.name;
  return s.identifier;
}

AQ.Sample.getter(AQ.User,"user");