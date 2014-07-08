Krill.prototype.step_title = function(s) {

  if ( !s ) { 

    return "??";

  } else if ( s.operation == 'display' ) {

    var title = "-";

    if ( s ) {
      for ( var i=0; i<s.content.length; i++ ) {
  	if ( s.content[i].title ) {
  	    title = s.content[i].title;
  	}
      }
    }

    return title;

  } else if ( s.operation == 'error' ) {

    return "Error"

  } else {

    return "Completed"

  }

}

Krill.prototype.info = function() {

  $('#krill-info').empty();

  var note = "";

  if ( this.pc == -2 ) {
    note = "<br />(completed, <a href='log?job="+this.job+"'>view log</a>)";
  }
  var job_info = $('<div>Job '+this.job+'<br />'+this.path+' '+note+'</div>').addClass('krill-job-info');
  $('#krill-info').append(job_info);

}

Krill.prototype.history = function() {

  var that = this;
  var n = 1;
  that.history_tag.empty();

  for ( var i=0; i<this.state.length; i+=2 ) {

    var t = new Date(this.state[i].time).format("h:MM:ss TT");

    var time  = $('<div>'+t+'</div>').addClass('krill-history-time');
    var title = $('<div>'+this.step_title(this.state[i+1])+'</div>').addClass('krill-history-title');
    var step = $('<div></div>').addClass('krill-history-step').append(time,title);

    (function(num) {
      step.click(function() {
       that.carousel_move_to(num,250);
       $(".krill-history-step").removeClass('krill-history-step-selected');
       $(this).addClass('krill-history-step-selected');
     });
    })(n);

    that.history_tag.append(step);

    if ( n == this.step_list.length ) {
     step.addClass('krill-history-step-selected');
   }

   n++;

 }

}
