function Krill(job,path,pc,metacol) {

    var that = this;

    this.steps_tag     = $('#steps');                               // element where step list should be put
    this.history_tag   = $('#history');
    this.inventory_tag = $('#inventory');
    this.uploads_tag   = $('#uploads');
    this.tasks_tag   = $('#tasks');
    this.metacol = metacol;
    this.job = job;
    this.path = path;
    this.pc = pc;

    this.step_list = [];                                              // list of all step tags for easy access
    this.step_list_tag = $('<ul id="step_list"></ul>').addClass('krill-step-list');  // document ul containing step tags

    this.check_again = false;

    _.templateSettings = {
        interpolate: /\{\{\=(.+?)\}\}/g,
        evaluate: /\{\{(.+?)\}\}/g
    };

}

Krill.prototype.initialize = function() {

    // First, initialize the steps list
    $('#krill-waiting').css('display','block');
    this.steps_tag.append(this.step_list_tag);
    this.get_state(); // get_state() calls render when data arrives
    
    var that = this;
    $('#krill-note').click(function(){
        var b = $("#Job_"+that.job+"_discussion_button");
        b.click();
    });
    $('#krill-abort').click(function(){that.abort();});

    $(window).keyup(function(e) {

      if ( e.keyCode == 39 /* arrow right */ ) {

        if ( that.current_position == that.step_list.length && that.ok_to_advance() ) {            

          that.carousel_move_to(that.step_list.length,250);

          if ( that.check_again ) {
            that.send("check_again",this);
          } else {
            that.send("next",this);
          }

        } else {

          e.preventDefault();            
          that.carousel_inc(1);  

        }

      } else if ( e.keyCode == 37 /* arrow left */ ) {

        that.carousel_inc(-1);  

      }

    });

}

Krill.prototype.ok_to_advance = function() {
  var last = this.state[this.state.length -1];
  return last.operation != 'complete' && last.operation != 'error';
}

Krill.prototype.update = function() {

    this.add_latest_step();
    this.info();
    this.history();
    this.inventory();
    this.uploads();
    this.tasks();

}

Krill.prototype.render = function() {

    $('#krill-waiting').css('display','none');

    // keep track of step number
    var n=1;

    // Check that the Krill server has responded
    if ( this.result.response == "not_ready" ) {
	   alert ( "Warning: This protocol is still preparing its next step(s). Try reloading this page to get the latest step." );
    }

    if ( this.state.length % 2 != 0 ) {
       alert ( "This protocol has an inconsistent backtrace." );
    }

    // Go through each step and add it to the display
    // The state looks like [ initialize, display, next, display, next, ..., display, next, complete|error ]
    //                        0           1        2     3        4          2n+1     2n+2  2n+3
    for ( var i=1; i<this.state.length; i += 2 ) {

        // Make an html element to containt the content
        var content = this.step(this.state[i],n);

        // Put the content in an li
        var s = $('<li id="l'+n+'"></li>')
            .addClass('krill-step-list-item')
            .append($('<div></div>')
              .addClass('krill-step-container')
              .append(content));

        // Add the content into the document and a separate list of tags for easy access
        this.step_list.push(s);
        this.step_list_tag.append(s);

        // Disable steps that have already been performed
        if ( i < this.state.length-2 ) {
           this.disable_step(s,this.state[i+1].inputs);
        }

        // Increment step number
        n++;

    }

    // Then render the history and inventory
    this.info();
    this.history();
    this.inventory();
    this.uploads();
    this.tasks();

    // Set up the carousel
    this.carousel_setup();
    this.resize();
    this.carousel_last();

}

Krill.prototype.disable_step = function(step,user_input) {

    step.addClass('krill-step-disabled');

    ///////////////////////////////////////////////////////////////////////////////////////////////
    var inputs = $(".krill-input-box",step);

    for ( var i=0; i<inputs.length; i++ ) {
        inputs[i].disabled = true;
        $(inputs[i]).val(user_input[$(inputs[i]).attr('id')]);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    var selects = $(".krill-select",step);

    for ( var i=0; i<selects.length; i++ ) {
        selects[i].disabled = true;
        $(selects[i]).val(user_input[$(selects[i]).attr('id')]);
    }

    $(".krill-next-btn",step).addClass('krill-next-btn-disabled');
    if ($(".krill-next-btn",step).length > 0 ) {
        $(".krill-next-btn",step)[0].disabled = true;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    var uploads = $(".krill-upload",step);

    for ( var i=0; i<uploads.length; i++ ) {
        var varname = $(uploads[i]).attr('id');
        $(uploads[i]).empty();
        list = $('<li></li>').addClass('list krill-upload-list');
        if ( user_input[varname] ) {
            for ( var j=0; j<user_input[varname].length; j++ ) {
                list.append(
                    $(this.template('uploaded-item')({
                        name: user_input[varname][j].name,
                        id: user_input[varname][j].id
                })));
            }
        }
        $(uploads[i]).append(list);

    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    $(".krill-timer",step).each(function() { console.log($(this)); $(this).data("krill_timer").stop(); })

}

Krill.prototype.add_latest_step = function() {

    var last = this.state.length-1;

    // Disable previous step
    this.disable_step(this.step_list[this.step_list.length-1],this.state[last-1].inputs);

    // Build last step
    var current = this.state[last];
    var content = this.step(current,(last+1)/2);

    // Add last step to lists
    var s = $('<li></li>').addClass('krill-step-list-item').append($('<div></div>').addClass('krill-step-container').append(content));
    s.css('width',$('#krill-steps-ui').outerWidth()-102).css('height', window.innerHeight - 90);
    this.step_list.push(s);
    this.step_list_tag.append(s);

}

Krill.prototype.build_titlebar = function(number,with_button) {  

    var that = this,
        titlebar = $(this.template('titlebar')({number: number})),
        btnholder = $('.krill-btn-holder',titlebar);

    if(with_button) {

        btn = $('<button id="next">OK</button>').addClass('krill-next-btn');
        btnholder.append(btn);

        btn.click(function() { // USER CLICKS 'OK' ////////////////////////////////////////////////////////////////////

            if ( that.check_again ) {
                that.send("check_again",this);
            } else {
                that.send("next",this);
            }

        }); ///////////////////////////////////////////////////////////////////////////////////////////////////////////

    }

    return titlebar;

}

Krill.prototype.log_link = function() { 

    var that = this;

    var btn = $('<button>View Log</button>').addClass('btn').click(function(){
        window.location = 'log?job=' + that.job;
    });

    return $('<li \>').append(btn).addClass('krill-note');

}

Krill.prototype.operations_link = function() { 

    var that = this;

    var btn = $('<button>Back to Manager</button>').addClass('btn').click(function(){
        window.location = '/operations';
    });

    return $('<li \>').append(btn).addClass('krill-note');

}

Krill.prototype.step = function(state,number) {    

    var container = $('<div></div>').addClass('krill-step');

    if ( !state ) {

        return;

    } else if ( state.operation == 'display' ) {

        var description = state.content;
        var titlebar = this.build_titlebar(number,true);
        var ul = $('<ul></ul').addClass('krill-step-ul');

        for(var i=0; i<description.length; i++) {

            var key = Object.keys(description[i])[0];
            if ( this[key] ) {
              var new_element = this[key](description[i][key],$('#title',titlebar));
              if ( new_element ) {
                ul.append(new_element);
              }
            } else {
              ul.append('<li>Unknown display request <b>'+key+'</b>: '+JSON.stringify(description[i][key])+'</li>');
            }

        }

        container.append(titlebar,ul).css('width',$('#krill-steps-ui').outerWidth());
        container.css('width',$('#krill-steps-ui').outerWidth()-102);
        container.css('height', window.innerHeight - 90 );

    } else if ( state.operation == 'error' ) {

        this.pc = -2;

        var titlebar = this.build_titlebar("!",false);
        $('#title',titlebar).html('Error');

        var ul = $('<ul></ul>').addClass('krill-step-ul');
        var p = $('<li><b>'+state.message+'</b></li>').addClass('krill-warning');

        ul.append(p);

        $.each(state.backtrace,function(el) {
            var line_info = state.backtrace[el].replace('(eval):', 'line: ');
            ul.append($('<li>'+line_info+'</li>').addClass('krill-note'));
        });

        ul.append(this.log_link(),this.operations_link());
        container.append(titlebar,ul);

    } else {

        this.pc = -2; // COMPLETED
        
        var ul = $('<ul></ul>').addClass('krill-step-ul');

        if ( this.result.response == "error" ) {
          var titlebar = this.build_titlebar("!",false);
          $('#title',titlebar).html('Error');
          var p = $('<li>'+this.result.error+'</li>').addClass('krill-note');
        } else {         
          if ( state.operation == "complete" ) {
            var titlebar = this.build_titlebar("&#10003;",false);
            $('#title',titlebar).html('Completed' );
            var p = $('<li>This protocol completed normally.</li>').addClass('krill-note');
          } else if ( state.operation == "aborted" ) {
            var titlebar = this.build_titlebar("&#10007",false);
            $('#title',titlebar).html('Aborted' );
            var p = $('<li>This protocol was aborted.</li>').addClass('krill-note');
          }
        }


        ul.append(p);
        ul.append(this.log_link(),this.operations_link());

        container.append(titlebar,ul);

    }

    var that = this;
    container.on("swipeleft", function(){that.carousel_inc(1)});  
    container.on("swiperight",function(){that.carousel_inc(-1)});  

    return container;

}

Krill.prototype.item_li = function(item) {

  var li = $('<li>')
    .append("<span class='krill-inventory-item-id'>"+item.id+"</span>")
    .append("<span class='krill-inventory-object-type-name'>" 
        + item.object_type.name + "</span>");

  if ( item.sample_id ) { 
    li.append("<span class='krill-inventory-sample-name'>"
        + item.sample.name + "</span>");
  }

  li.click(function() {
    window.location = '/items/' + item.id;
  });

  return li;

}

//////////////////////////////////////////////////////////////////////////////////////////
// PROCESS INPUTS
//

Krill.prototype.get = function() {

    // Returns an object containing the values of the inputs, if any

    var inputs = $(".krill-input-box",this.step_list[this.step_list.length-1]);
    var selects = $(".krill-select",this.step_list[this.step_list.length-1]);
    var table_inputs = $(".krill-table-input",this.step_list[this.step_list.length-1]);
 
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

    values.table_inputs = [];
    $.each(table_inputs,function(i,e) {
        values.table_inputs.push({ 
            value: $(e).val(), 
            opid: $(e).data('opid'), 
            key: $(e).data('key'),
            type: $(e).data('type')
        });
    });

    var a = [];

    var upload_containers = $(".krill-upload",this.step_list[this.step_list.length-1]);

    $.each(upload_containers,function(j,f) {

        var varname = $(f).attr("id");
        var uploads = $(".krill-upload-complete",$(f));

        $.each(uploads,function(i,e) {
            var ids   = $('.krill-upload-id',$(e));
            var names = $('.krill-upload-name',$(e));
            for ( var i=0; i<ids.length; i++ ) {
                a[a.length] = { 
                    id: parseInt($(ids[i]).html()),
                    name: $(names[i]).html().trim()
                };
            }
            values[varname] = a;
        });

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
        async: true
    }).done(function(data){
        that.state = data.state;
        that.result = data.result;
        that.render();
    }).fail(function(data){
        console.log("Error: " + data);
    });

}

Krill.prototype.send = function(command,button) {

    var inputs = this.get();
    var that = this;

    $(button).attr("disabled","disabled");
    $(button).addClass('krill-next-btn-disabled');
    $('#krill-waiting').css('display','block');

    $.ajax({

        // type: "POST",
        url: "next?command=" + command +'&job=' + that.job,
        type:'POST',
        data: { inputs: JSON.stringify(inputs) },
        async: true,
        dataType: "json",

    }).done(function(data){

        that.state = data.state;
        that.result = data.result;

        if ( that.result.response == "ready" ) {
            that.update();
            that.carousel_inc(1);
        } else if ( that.result.response == "done" ) {
            location.reload();
        } else {
            alert ( "The protocol is still preparing the next step. Please try clicking 'OK' again or reloading the page.")
        }

        $(button).removeAttr('disabled');
        $(button).removeClass('krill-next-btn-disabled');
        $('#krill-waiting').css('display','none');

    }).fail(function(data){

        console.log("Error: "+data);

    });

}

Krill.prototype.abort = function() {

    var that = this;

    $.ajax({
        url: 'abort?job=' + that.job,
        async: true
    }).done(function(data){
        if (data.response == "error" ) {
            alert ( "Could not stop job: " + data.error );
        } else {
            location.reload(); // redraws everything
        }
    }).fail(function(data){
        console.log("Error: " + data);
    });

}


