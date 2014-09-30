
function KrillTimer(t0) {

  this.t = t0;
  this.past = false;
  this.color = 'yellow';

  this.target = new Date();
  this.target.setHours(this.target.getHours() + t0.hours);
  this.target.setMinutes(this.target.getMinutes() + t0.minutes);
  this.target.setSeconds(this.target.getSeconds() + t0.seconds);

  this.el = $('<div />').addClass("krill-timer");
  this.el.data("krill_timer",this);
  this.render();

  this.beep = new Audio('/audios/beep.wav');

  //return this.el;

}

KrillTimer.prototype.element = function() {
  return this.el;
}


KrillTimer.prototype.render = function() {

  var neg = $("<span>&nbsp;</span>");

  if ( this.past ) {

    neg = $("<span>-</span>");
    if ( this.color == 'yellow' ) {
      this.color = 'red';
    } else {
      this.color = 'yellow';
    }
    $('#timer').css('background', this.color);
    this.beep.play();

  }

  this.h = $("<span id='hours'>" + this.pad(this.t.hours) + ":</span>");
  this.m = $("<span id='hours'>" + this.pad(this.t.minutes) + ":</span>");
  this.s = $("<span id='hours'>" + this.pad(this.t.seconds) + "</span>");

  this.el.empty().append(neg).append(this.h).append(this.m).append(this.s);

}

KrillTimer.prototype.pad = function (num) {

  var s = "0" + num;
  return s.substr(s.length-2);

}

KrillTimer.prototype.start = function() {

  var that = this;

  this.interval_id = setInterval(function () {

    var current_date = new Date().getTime();
    var seconds_left = (that.target - current_date) / 1000;

    if ( seconds_left <= 0 ) {
        that.past = true;
        seconds_left = -seconds_left;
    }

    seconds_left = seconds_left % 86400;
   
    that.t.hours = parseInt(seconds_left / 3600);
    seconds_left = seconds_left % 3600;
    that.t.minutes = parseInt(seconds_left / 60);
    that.t.seconds = parseInt(seconds_left % 60);

    that.render();

  }, 1000);

}

KrillTimer.prototype.stop = function() {
  clearInterval(this.interval_id);
}

Krill.prototype.timer = function(x) {
  kt = new KrillTimer(x.initial);
  kt.start();
  return kt.element();
}
