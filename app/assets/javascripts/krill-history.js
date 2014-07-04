Krill.prototype.step_title = function(s) {

    var title = "-";

    if ( s ) {
      for ( var i=0; i<s.content.length; i++ ) {
  	if ( s.content[i].title ) {
  	    title = s.content[i].title;
  	}
      }
    }

    return title;

}

Krill.prototype.history = function() {

    var that = this;
    var n = 1;
    that.history_tag.empty();

    for ( var i=0; i<this.state.length; i+=2 ) {

        console.log(this.state[i]);

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
