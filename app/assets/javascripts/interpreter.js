
function ArgumentUI(sha,args,cart,objects) {

    this.sha = sha;
    this.args = args;
    this.cart = cart;
    this.objects = objects;
    this.groups = [];
    this.users = [];
    this.timing = false;

}

ArgumentUI.prototype.display_form = function() {

    var that = this;

    for ( var i in args ) {

        var label = this.label(args[i]);
        var type = args[i]; 

        var form = this[args[i].type](args[i]);
        form.attr('id','arg-'+args[i].name);

        var well = $('<div></div>');
        well.addClass('argument');
        well.append(label,form);

        $('#argument-chooser').append(well);

    }

    if ( this.metacol ) {

      $('#button-area').append(
	  $('<button>Launch!</button>')
              .addClass('btn btn-primary')
              .click(function(e){that.submit()})
      );

    } else if ( this.edit ) {

      $('#button-area').append(
	  $('<button>Save New Arguments</button>')
              .addClass('btn btn-primary')
              .click(function(e){that.submit()})
      );

    } else {

      $('#button-area').append(
	  $('<button>Scheule New Job</button>')
              .addClass('btn btn-primary')
              .click(function(e){that.submit()})
      );

    }

}

ArgumentUI.prototype.submit = function() {

    var info = {}

    // Arguments
    var argvals = {};
    for ( var i in this.args ) {
	argvals[this.args[i].name] = this[get_name = 'get_' + this.args[i].type](this.args[i]);
    }
    info.args = argvals;

    // Group
    if ( this.groups && this.groups != [] ) {
        info.group = $('#group-chooser').find('select').val();
    }

    // Timing
    if ( this.timing ) {
	var date = $('#datepicker').val();
        var hours = $('#hours').val();
        var minutes = $('#minutes').val();
        info.date = (new Date(hours + ":" + minutes + ' ' + date )).getTime()/1000;
        info.window = $('#window').val();
    }

    if ( this.metacol ) {
      window.location = 'launch?sha=' + this.sha + '&path=' + this.path + '&info=' + encodeURIComponent(JSON.stringify(info));
    } else if ( this.edit ) {
      window.location = 'resubmit?job=' + this.job + '&info=' + encodeURIComponent(JSON.stringify(info));
    } else {
      window.location = 'submit?sha=' + this.sha + '&info=' + encodeURIComponent(JSON.stringify(info));
    }

}

ArgumentUI.prototype.get_number = function(arg) {
    return parseFloat($('#arg-'+arg.name).val());
}

ArgumentUI.prototype.get_string = function(arg) {
    return $('#arg-'+arg.name).val();
}

ArgumentUI.prototype.get_sample = function(arg) {
    return parseInt($('#arg-'+arg.name).val());
}

ArgumentUI.prototype.get_objecttype = function(arg) {
    return $('#arg-'+arg.name).find('p').text();
}

ArgumentUI.prototype.get_number_array = function(arg) {

   var na = [];

   $('#arg-'+arg.name).find('ol').find('li').each(function(e){ 
       na.push(parseFloat($(this).find('input').val()));
   });

   return na;
}

ArgumentUI.prototype.get_string_array = function(arg) {
 
   var sa = [];

   $('#arg-'+arg.name).find('ol').find('li').each(function(e){ 
       sa.push($(this).find('input').val());
   });

    return sa;
}

ArgumentUI.prototype.get_sample_array = function(arg) {
 
   var sa = [];

   $('#arg-'+arg.name).find('ol').find('li').each(function(e){ 
     sa.push(parseInt($(this).find('select').val()));
   });

   return sa;

}

ArgumentUI.prototype.get_array = function(arg) {
    var list = $('#arg-'+arg.name).find('ol');
}

ArgumentUI.prototype.label = function(arg) {

    return $('<div />').append($('<label />')
      .html( '<b>' + arg.name + "</b>: " 
            + arg.description 
            + ' ( ' + arg.type.replace('_', ' ') + ' ) '));

}

ArgumentUI.prototype.number = function(arg) {

    var x = $('<input></input>');
    x[0].type = 'number';
    x[0].step = 'any';
    if ( arg.current ) { 
      x[0].value = arg.current;
    }
    return x;

}

ArgumentUI.prototype.string = function(arg) {

    var x = $('<input />');
    x[0].type = 'text';
    if ( arg.current ) { 
      x[0].value = arg.current;
    }
    return x;

}

ArgumentUI.prototype.sample = function(arg) {

    var x = $('<select />');
   
    var sample_type = arg.name.replace(/_[^_]*$/,'').replace(/_/g,' ');

    if ( sample_type != arg.name ) {
       sample_type = sample_type.charAt(0).toUpperCase() + sample_type.slice(1);
    }

    var found = false;
 
    for ( var i in this.cart ) {

      if ( sample_type == arg.name || sample_type == this.cart[i].sample_type ) {
        if ( arg.current && arg.current == this.cart[i].id ) {
          found = true;
  	  x.append('<option selected value=' + this.cart[i].id + '>' + this.cart[i].id + ': ' + this.cart[i].sample_name + '</option>' );
        } else {
   	  x.append('<option value=' + this.cart[i].id + '>' + this.cart[i].id + ': ' + this.cart[i].sample_name + '</option>' );
        }
      }

    }

    if ( arg.current && !found ) {
      x.append('<option selected value=' + arg.current + '>' + arg.current + ': ' + arg.sample + '</option>' );
    }

    return x;

}

ArgumentUI.prototype.objecttype = function(arg) {

    var x = $('<div class="object-menu" />');
    var choice = $('<div class="choice"/>');

    if ( arg.current ) {
      choice.append('<p class="object-name">' + arg.current + '</p>');
    } else {
      choice.append('<p class="object-name">1 L Bottle</p>');
    }

    x.append(choice);    

    var top = $('<ul />');
    var title = $('<a href="#">Choose Object</a>' );
    var top_li = $('<li />');
    var handlers = $('<ul />');


    for ( var handler in this.objects ) {
	var h = $('<li />');

        h.append('<a href="#">' + handler + '</a>' );
        handlers.append(h);
        var objects = $('<ul />');
        for ( var i in this.objects[handler] ) {
            var name =  this.objects[handler][i]
            var ob = $('<li />');
            ob.append('<a href="#">' + name + "</a>");
            (function(x){
              ob.click(function(e) {
  		choice.html('<p class="object-name">' + x + '</p>');
              });
            }(name));
            objects.append(ob);
	}
        h.append(objects);
    }

    top_li.append(title)
    top_li.append(handlers)
    top.append(top_li);
    top.menu();

    x.append(top);
    x.css('z-index',10);

    return x;

}

ArgumentUI.prototype.number_array = function(arg) {
    return this.array(arg,'number');
}

ArgumentUI.prototype.string_array = function(arg) {
    return this.array(arg,'string');
}

ArgumentUI.prototype.sample_array = function(arg) {
    return this.array(arg,'sample');
}

ArgumentUI.prototype.array = function(arg,base) {
  
    var that = this;
   
    var l = $('<ol start="0" />');

    if ( !arg.current ) {
      var li = $('<li />');
      li.append(this[base](arg));
      l.append(li);
    } else {
      var a = eval(arg.current.replace(/&quot;/g, '"'));
      if ( base == 'sample' ) {
        var names = eval(arg.sample);
      }
      for ( var i in a ) {
        var li = $('<li />');
        if ( base == 'sample' ) {
          li.append(this[base]({current: a[i], sample: names[i]}));
        } else {
          li.append(this[base]({current: a[i]}));
        }
        l.append(li);
      }
    }

    var more = $('<button>+</button>');
    more.addClass('btn btn-small sep');

    more.click(function(e){
        var li = $('<li />');
        li.append(that[base](arg));
        l.append(li);
    });

    var less = $('<button>-</button>');
    less.addClass('btn btn-small sep');

    less.click(function(e){
	l.find('li:last').remove();
    });

    var x = $('<div />');
    x.append(l,more,less);

    return x;

}

ArgumentUI.prototype.display_groups = function(groups,users,current) {

    this.groups = groups;
    this.users = users;
 
    label = $('<label>Group / User</label>');

    select = $('<select />');

    for ( var i in groups ) {
	select.append('<option value=' + groups[i] + '>' + groups[i] + '</option>' );
    }

    select.append('<optgroup label="----------"></optgroup>');

    for ( var i in users ) {
        if ( users[i] == current ) {
            select.append('<option selected value=' + users[i] + '>' + users[i] + '</option>' );
        } else {
            select.append('<option value=' + users[i] + '>' + users[i] + '</option>' );
        }
    }

    $('#group-chooser').append(label,select);

}

ArgumentUI.prototype.display_timing = function() {

    this.timing = true;

    var d = new Date(),
      output = [
          ('0' + (d.getMonth() + 1)).substr(-2), 
          ('0' + d.getDate()).substr(-2), 
          d.getFullYear()
      ].join('/');

    $('#choose-date').append( $('<input type="text" id="datepicker" />') );

    hours = $('<select id = "hours" />');
    hours.css('width',80);

    for ( i=0; i<24; i++ ) {
	if ( i == d.getHours() ) {
	    hours.append('<option selected value=' + i + '>'+i+'</option>');
	} else {
	    hours.append('<option value=' + i + '>'+i+'</option>');
	}
    }

    minutes = $('<select id = "minutes" />');
    minutes.css('width',80);

    for ( i=0; i<59; i++ ) {
	if ( i == d.getMinutes() ) {
	    minutes.append('<option selected value=' + i + '>'+i+'</option>');
	} else {
	    minutes.append('<option value=' + i + '>'+i+'</option>');
	}
    }


   $('#choose-time').append( hours, $('<span> : </span>'), minutes );

   $('#choose-window').append(
     $("<select id='window' name='window'>"
      + "<option value='0.5'>1/2 Hour</option>"
      + "<option value='1'>1 Hour</option>"
      + "<option value='2'>2 Hours</option>"
      + "<option value='4'>4 Hours</option>"
      + "<option value='8'>8 Hours</option>"
      + "<option value='12'>12 Hours</option>"
      + "<option value='24' selected>1 Day</option>"
      + "<option value='48'>2 Days</option>"
      + "<option value='72'>3 Days</option>"
      + "<option value='96'>4 Days</option>"
      + "<option value='120'>5 Days</optio>"
      + "<option value='144'>6 Days</option>"
      + "<option value='168'>7 Days</option></select>") );

    $('#datepicker').datepicker({ minDate: new Date(), defaultDate: new Date(), gotoCurrent: true }).val(output);

}