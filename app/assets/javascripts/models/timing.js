AQ.Timing.record_getters.start_time = function() {
  var t = this;
  delete t.start_time;
  t.start_time = { hour: Math.floor(t.start/60), minute: t.start%60 };
  return t.start_time;
}

AQ.Timing.record_getters.stop_time = function() {
  var t = this;
  delete t.stop_time;
  t.stop_time = { hour: Math.floor(t.stop/60), minute: t.stop%60 };
  return t.stop_time;
}

AQ.Timing.record_getters.days_of_week = function() {

  var t = this;
  delete t.days_of_week;

  try {
    t.days_of_week = JSON.parse(t.days);
  } catch (e) {
    t.days_of_week = [];
  }

  return t.days_of_week;

}

AQ.Timing.record_methods.recomput = function() {
  var t = this;
  t.recomupte_getter("start_time");
  t.recomupte_getter("stop_time");
  t.recomupte_getter("days_of_week");   
}

AQ.Timing.record_methods.set = function(data) {

  // Format: {
  //  start: { hour: 8, minute: 30 },
  //  stop: { hour: 9, minute: 0 },
  //  days_of_week: [ "Tu", "Th" ]
  // }

  var t = this;

  t.start = data.start.hour * 60 + data.start.minute;
  t.stop = data.stop.hour * 60 + data.stop.minute;
  t.days = JSON.stringify(data.days_of_week);

  if ( t.id ) {
    console.log("put");
    AQ.http.put("/timings/" + t.id, { timing: t }).then(t.recompute);
  } else {
    console.log("post");    
    AQ.http.post("/timings", { timing: t }).then(t.recompute);
  }

}