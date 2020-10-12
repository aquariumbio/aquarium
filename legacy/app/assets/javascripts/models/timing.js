AQ.Timing.default = function() {

  return AQ.Timing.record({
    start: 8*60,
    stop: 8*60+30,
    days: "[\|Mo\"]",
    active: false
  });

}

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
  t.recompute_getter("as_string");   
}

AQ.Timing.record_methods.save = function() {

  var t = this;

  t.start = t.start_form.hour * 60 + t.start_form.minute;
  if ( t.start_form.ampm == "pm" && t.start_form.hour != 12  ) { t.start += 12*60; }
  t.stop = t.stop_form.hour * 60 + t.stop_form.minute;
  if ( t.stop_form.ampm == "pm" && t.stop_form.hour != 12 ) { t.stop += 12*60; }
  t.days = JSON.stringify(
    aq.where(["Su","Mo","Tu","We","Th","Fr","Sa"], w => t[w] )
  );

  if ( t.id ) {
    AQ.http.put("/timings/" + t.id, { timing: t }).then(t.recompute);
  } else {
    AQ.http.post("/timings", { timing: t }).then(t.recompute);
  }

}

AQ.Timing.record_methods.make_form = function() {

  var t = this,
      start_hour = Math.floor(t.start/60),
      stop_hour = Math.floor(t.stop/60);

  if ( start_hour == 12 ) {
    start_ampm = "pm";
  } else if ( start_hour > 12 ) {
    start_hour -= 12;
    start_ampm = "pm";
  } else {
    start_ampm = "am";
  }

  if ( stop_hour == 12 ) {
    stop_ampm = "pm";
  } else if ( stop_hour > 12 ) {
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
    t[m] = t.days_of_week ? (t.days_of_week.indexOf(m) >= 0) : false
  });

  return t;

}

AQ.Timing.format = function(data) {
  var m = data.minute;
  if ( m < 10 ) {
    m = "0" + m;
  }
  return data.hour + ":" + m + " " + data.ampm;
}

AQ.Timing.record_getters.as_string = function() {

  var t = this;

  delete t.as_string;
  t.make_form();

  t.as_string = AQ.Timing.format(t.start_form) + " to " 
              + AQ.Timing.format(t.stop_form);

  if ( t.days_of_week.length > 0 ) {
    t.as_string += ": " + t.days_of_week.join(", ");
  }

  return t.as_string;
}


AQ.Timing.minutes_since_midnight = function() {

  var d = new Date();
  return d.getHours() * 60 + d.getMinutes();

}

AQ.Timing.record_methods.compute_status = function() {

  var t = this;
  delete t.status;

  var m = AQ.Timing.minutes_since_midnight();

  if ( !t.active ) {
    t.status = 'none';
  } else if ( m < t.start ) {
    t.status = 'future';
  } else if ( t.start <= m && m <= t.stop ) {
    t.status = 'present';
  } else if ( t.stop < m ) {
    t.status = 'past';
  } else {
    t.status = 'none';
  }

  return t.status;

}

AQ.Timing.record_getters.status = function() {

  setInterval(this.compute_status, 1000);
  return this.compute_status();

}

