function Krill(job) {

    var that = this;

    this.step_tag    = $('#step');
    this.history_tag   = $('#history');
    this.inventory_tag   = $('#inventory');
    this.next_button = $('#next');

    this.job = job;

    this.next_button.click(function() {

        that.send_next();
        that.display();

    });

}

Krill.prototype.display = function() {

    this.step();
    this.history();
    this.inventory();

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

Krill.prototype.step = function() {

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

Krill.prototype.take = function(x) {

    var check = $('<input type="checkbox"></input>').addClass('krill-checkbox');
    var id = $('<span>' + x.id + ' </span>').addClass('krill-item-id');
    var name = $('<span>' + x.name + ' </span>').addClass('krill-item-name');
    var loc = $('<span>' + x.location + ' </span>').addClass('krill-item-location');

    var tag = $('<li></li>').append(check,id,name,loc);

    if ( x.sample ) {

        var sample = $('<span>' + x.sample + ' </span>').addClass('krill-item-sample');
        var type =  $('<span>' + x.type + ' </span>').addClass('krill-item-type');
	tag.append(sample,type);
    }

    return tag;

}

Krill.prototype.table = function(x) {

    var tab = $('<table></table>').addClass('krill-table');

    for( var i=0; i<x.length; i++) {
        var tr = $('<tr></tr>')
	for( var j=0; j<x[i].length; j++ ) {
            console.log(x[i][j] + ": " + typeof x[i][j]);
            if ( typeof x[i][j] != "object" ) {
               var td = $('<td>'+x[i][j]+'</td>');
            } else {
		var td = $('<td>'+x[i][j].content+'</td>');
                if ( x[i][j].check ) {
		    td.addClass('krill-td-check');
                    (function(td) {
  		      td.click(function() {
			if ( td.hasClass('krill-td-selected') ) {
			    td.removeClass('krill-td-selected');
			} else {
			    td.addClass('krill-td-selected');
			}
		      });
                    })(td);
		}
	    }
	    tr.append(td);
	}
	tab.append(tr);
    }

    return tab;

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