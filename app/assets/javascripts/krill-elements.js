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

    var mult = x.multiple ? "multiple" : ""

    var label = $('<span>' + x.label + '</span>').addClass('krill-select-label');
    var select = $('<select ' + mult + ' id="'+x.var+'"></select>').addClass('krill-select');

    for ( var i=0; i < x.choices.length; i++ ) {
	     select.append('<option>' + x.choices[i] + '</option>');
    }

    return $('<li></li>').append(label).append(select);

}

Krill.prototype.input = function(x) {

    var label = $('<span>' + x.label + '</span>').addClass('krill-input-label');
    var input = $('<input id="'+x.var+'" type='+x.type+'></input>').addClass('krill-input-box');;

    if ( x.default ) {
      input.attr('value',x.default);
    }

    return $('<li></li>').addClass('krill-input').append(label).append(input);

}

Krill.prototype.uploaded_item = function(upload_name,upload_id,varname) {

  var icon = $('<i />').addClass('icon-ok');
  var name = $('<span> '+upload_name+'</span>').addClass('krill-upload-name');
  var id = $('<span> (<span class="krill-upload-id">'+upload_id+'</span>)</span>');
  return $('<li />').addClass('krill-upload-complete').attr("id",varname).append(icon,name,id);

}

Krill.prototype.upload = function(x) {

  var that = this;
  var container = $('<div></div>').addClass('well row-fluid krill-upload');
  var span      = $('<div />').addClass('btn btn-success fileinput-button');
  var input     = $('<input type="file" name="files[]" data-url="/krill/upload?job='+this.job+'" multiple></input>').addClass('krill-uload-input');

  console.log ( "New upload with var = '"+x.var+"'" );

  span.append(
    $('<span>Attach files...</span>'),
    input);

  var list          = $('<ul />').addClass('list krill-upload-list');
  var button_holder = $('<div />').addClass('span3').append(span);
  var list_holder   = $('<div />').addClass('span9').append(list);

  container.append(button_holder,list_holder);

  $(function() {

    input.fileupload({

      dataType: 'json',

      done: function (e, data) {
        data.context.empty().append(that.uploaded_item(data.files[0].name,data.result.upload_id,x.var));
      },

      add: function (e,data) {
        var el = $('<li><i class="icon-time"></i> '+data.files[0].name+'</li>').addClass('krill-upload-waiting').attr("id",x.var);
        data.context = el;
        list.append(el);
        data.submit();
      },

      fail: function(e,data) {
        console.log('failed');
      }

    });
  });

  return container;

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

