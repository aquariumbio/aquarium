Krill.prototype.carousel_inc = function(num) {

    this.carousel_move_to(this.current_position + num,250);
}

Krill.prototype.carousel_move_to = function(num,dur) {

    var that = this;
    if ( dur ) {
	duration = dur;
    } else {
	duration = 5;
    }

    if ( 1 <= num && num <= this.step_list.length ) {    
      var item_width = this.step_list[0].outerWidth();  
      var left_indent = -num*item_width;  
      $('#step_list').animate({'left' : left_indent},{queue:false, duration:duration});
      this.current_position = num;
    }
}

Krill.prototype.carousel_setup = function() {

    var that = this;
    this.current_position = 1;

    // Insert blank step at beginning
    var blank = $('<li id="l0"></li>').addClass('krill-step-list-item').append($('<div></div>').addClass('krill-step').append($("<p>Blank</p>")));
    this.step_list_tag.prepend(blank);

    // Move forward
    $('#fwd').click(function(){that.carousel_inc(1)});  

    // Move in reverse    
    $('#rev').click(function(){that.carousel_inc(-1)});

}

Krill.prototype.carousel_last = function() {

    this.carousel_move_to(this.step_list.length);
}

//
// #krill-steps-ui
//    #steps
//      #step_list (ul)
//        .krill_step_list_item
//           .krill_step
//

Krill.prototype.resize = function() {

    // Heights
    var h = window.innerHeight - 90;
    $('#krill-steps-ui').css('height',h);      // UI
    $('.krill-carousel-btn').css('height',h);  // Button regions
    $('#steps').css('height',h)                // Step description container
    $('#step_list').css('height',h)            // Step list
    $('.krill-step-list-item').css('width',h); // Strep list item
    $('.krill-step').css('height',h-22);          // Step description
    $('#krill-tools').css('height',h);

    // Adjust widths
    var width = $('#krill-steps-ui').outerWidth(); 
    $('#steps').css('width',width-102);
    $('.krill-step-list-item').css('width',$('#steps').outerWidth());
    //$('.krill-step').css('width',$('#steps').outerWidth()-20);       

    // Move to first slide
    $('#step-list').css('left',-width+102);

    this.carousel_last(this.step_list.length);

    console.log('resize');

}