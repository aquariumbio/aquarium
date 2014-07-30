/////////////////////////////////////////////////////////////////////////////////////////////////////
// KRILL DISPLAY ELEMENTS
//

Krill.prototype.title = function(x,title_tag) {
    title_tag.html(x);
    return false;
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
    return $('<li><span>' + x + '<span></li>').addClass('krill-warning');
}

Krill.prototype.bullet = function(x) {
    return $('<li>' + x + '</li>').addClass('krill-bullet');
}

Krill.prototype.image = function(x) {
  return $("<li><img src=" + x + " class='krill-image'></img></li>");
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
    var id = $('<span>Item ' + x.id + ' </span>').addClass('krill-item-id');
    var name = $('<span>' + x.name + ' </span>').addClass('krill-item-name');
    var loc = $('<span>' + x.location + ' </span>').addClass('krill-item-location');
    var tag = $('<li></li>');

    if ( x.sample ) {
      var sample = $('<span>(' + x.sample + ')</span>').addClass('krill-item-sample');
      var type =  $('<span>' + x.type + ' </span>').addClass('krill-item-type');
    	tag.append(check,id,name,sample,loc);
    } else {
      tag.append(check,id,name,loc);
    }

    return tag;

}

Krill.prototype.separator = function(x) {
  return $('<li \>').addClass('krill-separator');
}

Krill.prototype.table = function(x) {

  var tab = $('<table></table>').addClass('krill-table');

  for( var i=0; i<x.length; i++) {

    var tr = $('<tr></tr>');

    for( var j=0; j<x[i].length; j++ ) {

      console.log(x[i][j]);

      if ( typeof x[i][j] != "object" ) {

        var td = $('<td>'+x[i][j]+'</td>');

      } else if ( x[i][j] == null ) {

        var td = $('<td></td>');

      } else {

        var td = $('<td>'+x[i][j].content+'</td>');

        if ( x[i][j].style ) {
          for ( var key in x[i][j].style ) {
            console.log(typeof key+":"+x[i][j].style[key]);
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

  return tab;

}

Krill.prototype.empty_table = function(r,c) {

  var t = $('<table></table>').addClass('krill-transfer-table');

  for(var i=0;i<=r;i++) {
    var tr = $('<tr />');
    for(var j=0; j<=c; j++) {
      if ( i==0 && j != 0 ) {
        tr.append($('<td>'+j+'</td>').addClass('index'));
      } else if ( i != 0 && j == 0 ) {
        tr.append($('<td>'+i+'</td>').addClass('index'));        
      } else if ( i == 0 && j == 0 ) {
        tr.append($('<td />').addClass('index'));       
      } else {
        tr.append('<td />');        
      }
    }
    t.append(tr);
  }

  return t;

}

Krill.prototype.transfer = function(x) {

  var container  = $('<div></div>').addClass('krill-transfer-container');
  var from = $('<div />').addClass('krill-from-container');
  var to = $('<div />').addClass('krill-to-container');

  var from_table = this.empty_table(x.from.rows,x.from.cols).addClass('krill-transfer-from');
  var to_table   = this.empty_table(x.to.rows,x.to.cols).addClass('krill-transfer-to');;
  var arrow      = $("<span><i class='icon-arrow-right' /></span>").addClass('krill-transfer-arrow');

  from.append($('<h3>'+x.from.id+': '+x.from.type+'</h3>'),from_table);
  to.append($('<h3>'+x.to.id+': '+x.to.type+'</h3>'),to_table);
  to.append(to_table);

  container.append(from,arrow,to)

  return container;

}


