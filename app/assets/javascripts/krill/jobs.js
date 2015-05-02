function JobLister() {

  var that = this;

  // RADIO BUTTONS
  $('#user-radio').click(function() {
    $('#user-select').prop('disabled', false);
    $('#group-select').prop('disabled', true);
    $.cookie('jobs-filter','user-radio');
    that.update();
  });

  $('#group-radio').click(function() {
    $('#user-select').prop('disabled', true);
    $('#group-select').prop('disabled', false);  
    $.cookie('jobs-filter','group-radio');    
    that.update();
  }); 

  $('#all-radio').click(function() {
    $('#user-select').prop('disabled', true);
    $('#group-select').prop('disabled', true);  
    $.cookie('jobs-filter','all-radio');
    that.update();
  });

  if ( $.cookie('jobs-filter') ) {
    $('#'+$.cookie('jobs-filter')).prop("checked",true).click();
  } else {
    $.cookie('jobs-filter','user-radio')
  }

  // USER/GROUP SELECT
  $('#user-select').change(function() {
    $.cookie('jobs-user',$(this).val());
    that.update();    
  }).val($.cookie('jobs-user'));

  $('#group-select').change(function() {
    $.cookie('jobs-group',$(this).val());
    that.update();    
  }).val($.cookie('jobs-group'));

  // TABS
  $('.job-tab').click(function() {
     $.cookie('jobs-selection',$(this).attr('id'));
  });

  if ( $.cookie('jobs-selection') ) {
    $('#'+$.cookie('jobs-selection')).tab('show');
  }

  if ( ! this.initialized ) {
    this.init();
  }

}

JobLister.prototype.user = function() {
  return $('#user-select').val();
}

JobLister.prototype.group = function() {
  return $('#group-select').val();
}

JobLister.prototype.update = function () {
  var that = this;
  for ( var t in this.tables ) {
    this.tables[t].ajax.url(
      "joblist?type=" + t
      + "&user_id="   + this.user()
      + "&group_id="  + this.group()
      + "&filter="    + $.cookie('jobs-filter')
    );
    this.tables[t].ajax.reload(function() {
      that.summarize();
    });
  }
}

JobLister.prototype.init = function () {

  var that = this;
  this.initialized = true;
  this.tables = {};

  $(".job-table").each(function() {
    var t = $(this).DataTable({
      "ajax": "joblist?type=" + $(this).attr('id') 
              + "&user_id="   + that.user()
              + "&group_id="  + that.group()
              + "&filter="    + $.cookie('jobs-filter'),
      "paging": false,
      "info": false,
      "ordering": false ,
      "searching": false,
      "initComplete": function() {
        that.summarize();
      }
    });
    that.tables[$(this).attr('id')] = t;
  });

}

JobLister.prototype.summarize = function () {
  $(".job-table").each(function() {
    var n = $(this).find(".jobs-jid").length;
    console.log($(this).attr('id') + " has " + n + " jobs");
    if ( n > 0 ) {
      $('#'+$(this).attr('id')+'-size').html(" ("+n+")");
    } else {
      $('#'+$(this).attr('id')+'-size').html("");     
    }
  });
}
