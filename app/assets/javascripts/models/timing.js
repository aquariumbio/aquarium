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

AQ.Timing.record_methods.recompute = function() {
  var t = this;
  t.recompute_getter("start_time");
  t.recompute_getter("stop_time");
  t.recompute_getter("days_of_week");   
}

AQ.Timing.record_methods.save = function() {

  var t = this;

  t.start = t.start_form.hour * 60 + t.start_form.minute;
  if ( t.start_form.ampm == "pm" ) { t.start += 12*60; }
  t.stop = t.stop_form.hour * 60 + t.stop_form.minute;
  if ( t.stop_form.ampm == "pm" ) { t.stop += 12*60; }
  t.days = JSON.stringify(
    aq.where(["Su","Mo","Tu","We","Th","Fr","Sa"], w => t[w] )
  );

  if ( t.id ) {
    AQ.http.put("/timings/" + t.id, { timing: t }).then(t.recompute);
    console.log("put")
  } else {
    AQ.http.post("/timings", { timing: t }).then(t.recompute);
    console.log("post")    
  }

}

AQ.Timing.record_methods.make_form = function() {

  var t = this,
      start_hour = Math.floor(t.start/60),
      stop_hour = Math.floor(t.stop/60);

  if ( start_hour > 12 ) {
    start_hour -= 12;
    start_ampm = "pm";
  } else {
    start_ampm = "am";
  }

  if ( stop_hour > 12 ) {
    stop_hour -= 12;
    stop_ampm = "pm";
  } else {
    stop_ampm = "am";
  }

  t.start_form = { 
      hour: start_hour,
      minute: t.start%60,
      ampm: start_ampm
    };

  t.stop_form = { 
      hour: stop_hour,
      minute: t.stop%60,
      ampm: stop_ampm
    };

  aq.each(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], m => {
    t[m] = t.days_of_week.indexOf(m) >= 0
  });

  return t;

}

AQ.Timing.default = function() {

  return AQ.Timing.record({
    start: 8*60,
    stop: 8*60+30,
    days: "[\|Mo\"]",
    active: false
  });

}
