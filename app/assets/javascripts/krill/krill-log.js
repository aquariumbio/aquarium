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
    while ( !show.content[i].title && i < show.content.length ) {
      i++;
    }
    return show.content[i].title;

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

  var v = val.var;
  var files = action.inputs[v];
  var li = $('<li />');
  var ul = $('<ul />');

  for ( var i=0; i<files.length; i++ ) {
    ul.append($(this.template('upload')({name: files[i].name, id: files[i].id})));
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

  if ( result.operation = 'display' ) {
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

KrillLog.prototype.take      = function(action,x) { return $(this.template('take')(x)); }

KrillLog.prototype.render = function(tag) {

  tag.addClass('krill-log');

  var ul = $('<ul />').addClass('krill-log-steps');
  tag.append(ul);

  for ( var i=1; i<this.history.length-1; i += 2) {
    ul.append($('<li />').append(this.step(this.history[i+1],this.history[i])));
  }

  var x = $('<p/>');
  render_json(x,this.history);
  tag.append(x);

}
