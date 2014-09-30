
function KrillGroupAndTiming() {

    this.groups = [];
    this.users = [];
    this.timing = false;

}

KrillGroupAndTiming.prototype.display_groups = function(groups,users,current) {

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

KrillGroupAndTiming.prototype.display_timing = function() {

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