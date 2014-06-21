function Krill(job) {

    var that = this;

    this.steps_tag    = $('#steps');                                 // element where step list should be put
    this.history_tag   = $('#history');
    this.inventory_tag   = $('#inventory');
    this.job = job;
   
    this.step_list = [];                                              // list of all step tags for easy access
    this.step_list_tag = $('<ul id="step_list"></ul>').addClass('krill-step-list');  // document ul containing step tags 



}

Krill.prototype.update = function() {

    if ( !this.check_if_done() ) {

      this.add_latest_step();
      this.history();
      this.inventory();

    }

}

Krill.prototype.initialize = function() {

    // First, initialize the steps list
    this.steps_tag.append(this.step_list_tag);
    this.get_state();
    var n=1;

    for ( var i=1; i<this.state.length; i += 2 ) {

        var content = this.step(this.state[i].content,n);
            
        var s = $('<li id="l'+n+'"></li>').addClass('krill-step-list-item').append($('<div></div>').addClass('krill-step-container').append(content));
        this.step_list.push(s);
        this.step_list_tag.append(s);

	if ( i < this.state.length-2 ) {
	    this.disable_step(s,this.state[i+1].inputs);
	}

        n++;

    }

    // Then render the history and inventory
    this.history();
    this.inventory();

    // Set up the carousel
    this.carousel_setup();
    this.resize();
    this.carousel_last();

}

Krill.prototype.disable_step = function(step,user_input) {

    step.addClass('krill-step-disabled');

    var inputs = $(".krill-input-box",step);

    for ( var i=0; i<inputs.length; i++ ) {
        inputs[i].disabled = true;
        $(inputs[i]).val(user_input[$(inputs[i]).attr('id')]);
    }

    var selects = $(".krill-select",step);

    for ( var i=0; i<selects.length; i++ ) {
        selects[i].disabled = true;
        $(selects[i]).val(user_input[$(selects[i]).attr('id')]);
    }

    $(".krill-next-btn",step)[0].disabled = true;

}

Krill.prototype.add_latest_step = function() {

    var last = this.state.length-1;

    // Disable previous step
    this.disable_step(this.step_list[this.step_list.length-1],this.state[last-1].inputs);

    // Build last step

    var current = this.state[last].content;

    var content = this.step(current,(last+1)/2);

    // Add last step to lists
    var s = $('<li></li>').addClass('krill-step-list-item').append($('<div></div>').addClass('krill-step-container').append(content));
    this.step_list.push(s);
    this.step_list_tag.append(s);

}

Krill.prototype.step = function(description,number) {

    var that = this;
    var num = $('<span>' + number + '</span>').addClass('krill-step-number');
    var ul = $('<ul></ul').addClass('krill-step-ul');
    var btn = $('<button id="next">Next</button>').addClass('btn').addClass('krill-next-btn');
    var container = $('<div></div>').addClass('krill-step');

    for(var i=0; i<description.length; i++) {

        var key = Object.keys(description[i])[0];
	ul.append(this[key](description[i][key]));

    }

    btn.click(function() {

        that.send_next();
        that.update();
        that.carousel_inc(1);

    });

    container.append(num,btn,ul);

    return container;

}

Krill.prototype.check_if_done = function() {

    var i = this.state.length-1;
    var last = this.state[i];
    var done = false;

    switch ( last.operation ) {

      case 'next':
        this.step_tag.empty().append('<p>Processing not complete. Reload page.</p>');
        done = false;
	break;
      case 'complete':
        window.location = 'completed?job=' + this.job;
        done = true;
	break;
      case 'error':
        window.location = 'error?job=' + this.job + '&message=' + last.message;
        done = true;
	break;

    }

    return done;

}

Krill.prototype.history = function() {

    try {
      render_json(this.history_tag.empty(),this.state);
    } catch(e) {
      this.history_tag.empty().append('<p>Error:'+e+'</p>');
    }

}

Krill.prototype.inventory = function() {

    var that = this;

    $.ajax({
        url: 'takes?job=' + that.job,
    }).done(function(data){

        var items = [];
        for ( var i in data ) {
            items.push(data[i].id);
        }
        console.log(items);
	that.inventory_tag.empty();
        render_json(that.inventory_tag,items);
    });

}


//////////////////////////////////////////////////////////////////////////////////////////
// PROCESS INPUTS
//

Krill.prototype.get = function() {

    // Returns an object containing the values of the inputs, if any

    var inputs = $(".krill-input-box",this.step_list[this.step_list.length-1]);
    var selects = $(".krill-select",this.step_list[this.step_list.length-1]);
    var values = { timestamp: Date.now()/1000 };

    $.each(inputs,function(i,e) {
        var name = $(e).attr("id");
        if($(e).attr("type")=="number") {
            values[name] = parseFloat($(e).val());
        } else {
            values[name] = $(e).val();
        }
    });    

    $.each(selects,function(i,e) {
        var name = $(e).attr("id");
        values[name] = $(e).val();
    });    

    return values;

}

/////////////////////////////////////////////////////////////////////////////////
// COMMUNICATION WITH RAILS
// 

Krill.prototype.get_state = function() {

    var that = this;

    $.ajax({
        url: 'state?job=' + that.job,
        async: false
    }).done(function(data){
        that.state = data;
    }).fail(function(data){
        console.log("Error: " + data);
    });

}

Krill.prototype.send_next = function() {

    var inputs = this.get();
    var that = this;

    $.ajax({
        // type: "POST",
        url: 'next?job=' + that.job,
        data: { inputs: inputs },
        async: false
    }).done(function(data){
        that.state = data;
    }).fail(function(data){
        console.log("Error:"+data);
    });

}