function Krill(job) {

    var that = this;

    this.step_tag    = $('#step');
    this.state_tag   = $('#state');
    this.next_button = $('#next');

    this.job = job;

    this.next_button.click(function() {
        that.send_next();
        that.display();
    });

}

Krill.prototype.display = function() {

    try {
      render_json($('#state').empty(),this.state);
    } catch(e) {
      $('#state').empty().append('<p>Error:'+e+'</p>');
    }

    var last = this.state[this.state.length-1];
 
    if ( last.operation == 'next' ) {

        this.step_tag.empty().append('<p>Processing not complete. Reload page.</p>');

    } else if ( last.operation == 'complete' ) {

        window.location = 'completed?job=' + this.job;

    } else if ( last.operation == 'error' ) {

        window.location = 'error?job=' + this.job + '&message=' + last.message;

    } else {

      var i = this.state.length-1;
      while(this.state[i].operation != 'display' && i>0) { i--; }

      if(i>0) {
	  this.current = this.state[i].content;
      } else {
	  this.current = { note: "Nothing to display. Try reloading." }
      }

      var ul = $('<ul></ul').addClass('krill-display-list');

      for(var i=0; i<this.current.length; i++) {

	  var key = Object.keys(this.current[i])[0];
	  ul.append(this[key](this.current[i][key]));

      }

      this.step_tag.empty().append(ul);

    }

}

/////////////////////////////////////////////////////////////////////////////////////////////////////
// FIELDS
//

Krill.prototype.title = function(x) {
    return $('<li>'+x+'</li>').addClass('krill-title');
}

Krill.prototype.note = function(x) {
    return $('<li>'+x+'</li>').addClass('krill-note');
}

Krill.prototype.check = function(x) {
    var check = $('<input type="checkbox"></input>').addClass('krill-checkbox');
    var span = $('<span>'+x+'</span>');
    return $('<li></li>').append(check).append(span).addClass('krill-check');
}

Krill.prototype.warning = function(x) {
    return $('<li>warning</li>').addClass('krill-warning');
}

Krill.prototype.select = function(x) {

    var label = $('<span>' + x.label + '</span>').addClass('krill-select-label');
    var select = $('<select id="'+x.var+'"></select>').addClass('krill-select');

    for ( var i=0; i < x.choices.length; i++ ) {
	select.append('<option>' + x.choices[i] + '</option>');
    }

    return $('<li></li>').append(label).append(select);
}

Krill.prototype.input = function(x) {

    var label = $('<span>' + x.label + '</span>').addClass('krill-input-label');
    var input = $('<input id="'+x.var+'" type='+x.type+'></input>').addClass('krill-input-box');;

    return $('<li></li>').addClass('krill-input').append(label).append(input);

}

//////////////////////////////////////////////////////////////////////////////////////////
// PROCESS INPUTS
//

Krill.prototype.get = function() {

    // Returns an object containing the values of the inputs, if any

    var inputs = $(".krill-input-box");
    var selects = $(".krill-select");
    var values = { timestamp: Date.now()/1000 };

    $.each(inputs,function(i,e) {
        var name = $(e).attr("id");
        if($(e).attr("type")=="number") {
            values[name] = parseFloat($(e).val());
            console.log(values[name]);
        } else {
            values[name] = $(e).val();
        }
    });    

    $.each(selects,function(i,e) {
        var name = $(e).attr("id");
        values[name] = $(e).val();
    });    

    console.log(values);

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
        console.log(data);
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
        console.log(data);
    });

}