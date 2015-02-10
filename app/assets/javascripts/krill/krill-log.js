function KrillLog(history) {
  this.history = history;
  _.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
  };
}

KrillLog.prototype.template = function(name) {
  return _.template($('#'+name+"-template").html());
}

KrillLog.prototype.title = function(show) {

  var i = 0;

  if ( show.content ) {

    while ( i < show.content.length && !show.content[i].title ) {
      i++;
    }
    if ( i < show.content.length ) {
      return show.content[i].title;
    } else {
      return "";
    }

  } else {
    return show.operation;
  }

}

KrillLog.prototype.note = function(action,val) {
  return $('<li />').append($('<span>'+val+'</span>'));
}

KrillLog.prototype.bullet = function(action,val) {
  return $('<li />').append($('<span>&#9900; '+val+'</span>'));
}

KrillLog.prototype.check = function(action,val) {
  return $('<li />').append($('<span>&#10003; '+val+'</span>'));
}

KrillLog.prototype.warning = function(action,val) {
  return $('<li />').append($('<span>'+val+'</span>').addClass('krill-log-warning'));
}

KrillLog.prototype.upload = function(action,val) {

  var v = "uploads";
  if ( val.var ) {
    v = val.var;
  }
  var files = [];
  if ( action.inputs ) {
    files = action.inputs[v];
  } 
  var li = $('<li />');
  var ul = $('<ul />');

  if ( files ) {
    for ( var i=0; i<files.length; i++ ) {
      ul.append($(this.template('upload')({name: files[i].name, id: files[i].id})));
    }
  }

  span = $('<span>Upload(s):</span>');
  li.append(span,ul);
  return li;

}

KrillLog.prototype.select = function(action,val) {

  var li = $('<li />');
  var v = val.var;
  li.append($(this.template('select')({label: val.label, answer: action.inputs[v] })));
  return li;

}

KrillLog.prototype.input = KrillLog.prototype.select;

KrillLog.prototype.table = function(action,x) {

  var tab = $('<table></table>').addClass('krill-log-table');

  for( var i=0; i<x.length; i++) {
    var tr = $('<tr></tr>');
    for( var j=0; j<x[i].length; j++ ) {
      if ( typeof x[i][j] != "object" ) {
        var td = $('<td>'+x[i][j]+'</td>');
      } else if ( x[i][j] == null ) {
        var td = $('<td></td>');
      } else {

        var td = $('<td>'+x[i][j].content+'</td>');

        if ( x[i][j].style ) {
          for ( var key in x[i][j].style ) {
            td.css(key,x[i][j].style[key]);
          }
        }

        if ( x[i][j].class ) {
          td.addClass(x[i][j].class);
        }

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

  return $('<li />').append(tab);

}

KrillLog.prototype.take = function(action,x) { 
  var y = x;
  if ( !y.sample ) {
    y.sample = null;
  }
  return $(this.template('take')(y));
}

KrillLog.prototype.part = function(action,key,val) {
  
  var li;

  if ( this[key] ) {
    li = this[key](action,val);
  } else {
    li = $('<li>' + key + '</li>');
  }

  return li;

}

KrillLog.prototype.step = function(action,result) {

  var div = $('<div />').addClass('krill-log-step');

  var time = $('<span>'+aq.nice_time(new Date(action.time))+'</span>').addClass('krill-log-time');
  var title = $('<span> - '+this.title(result)+'</span>').addClass('krill-log-title');
  var ul = $('<ul />').addClass('krill-part-list');

  if ( result.content ) {
    for ( var i=0; i < result.content.length; i++ ) {
      var part = result.content[i];
      var key = Object.keys(part)[0];
      var val = part[key];
      if ( key != 'title' && key != 'image' ) {
        ul.append(this.part(action,key,val));
      }
    }
  }

  div.append($('<div></div>').append(time,title).addClass('krill-step-heading'),ul);

  return div;

}

KrillLog.prototype.error = function(action,result) {

  var div = $('<div />').addClass('krill-log-step');

  var time = $('<span>'+aq.nice_time(new Date(action.time))+'</span>').addClass('krill-log-time');
  var title = $('<span> - '+this.title(result)+': ' + this.message + '</span>').addClass('krill-log-title ');
  var err = $('<div />').addClass('krill-log-json');

  render_json(err,result.backtrace)

  div.append($('<div></div>').append(time,title).addClass('krill-step-heading  krill-log-error'),err);

  return div;

}

KrillLog.prototype.intro = function(op) {

  var li = $(this.template('result')({time: aq.nice_time(new Date(op.time)), title: "Started protocol", klass: "krill-log-intro"}));
  render_json($('.krill-log-json',li),op.arguments);
  return li;

}


KrillLog.prototype.result = function(op) {

  if ( op.operation == 'complete' ) {
    var li = $(this.template('result')({time: "", title: "Completed", klass: "krill-log-complete"}));
    render_json($('.krill-log-json',li),op.rval);
    return li;
  } else if ( op.operation == 'aborted' ) {
    var li = $(this.template('result')({time: "", title: "Aborted", klass: "krill-log-abort"}));
    return li;
  }

}

KrillLog.prototype.render = function(tag) {

  tag.addClass('krill-log');

  var ul = $('<ul />').addClass('krill-log-steps');
  tag.append(ul);
 
  ul.append(this.intro(this.history[0]));

  for ( var i=1; i<this.history.length-1; i += 2) {

    var action = this.history[i+1],
        result = this.history[i];

    if ( result.operation == 'display' ) {
      ul.append($('<li />').append(this.step(action,result)));
    }

    if ( result.operation == 'error' ) {
      ul.append($('<li />').append(this.error(action,result)));
    }

  }

  ul.append(this.result(this.history[i]));

  // var x = $('<p/>');
  // render_json(x,this.history);
  // tag.append(x);

}
