/////////////////////////////////////////////////////////////////////////////////////////////////////
// KRILL DISPLAY ELEMENTS
//

Krill.prototype.template = function(name) {
  return _.template($('#'+name+"-template").html());
}

Krill.prototype.fix = function(x) {
  var y = x;
  y.variable = y.var;  // replace default and var with keys that don't
  y.dflt = y.default;  // conflict with javascript keywords
  if ( !("sample" in x)  ) {
    y.sample = null;
  } 
  if ( !("multiple" in x ) ) {
    y.multiple = false;
  }
  return y;
}

Krill.prototype.title = function(x,title_tag) {
    title_tag.html(x);
    return false;
}

Krill.prototype.note      = function(x) { return $(this.template('note')({content: x})); }
Krill.prototype.check     = function(x) { return $(this.template('check')({content: x})); }
Krill.prototype.warning   = function(x) { return $(this.template('warning')({content: x})); }
Krill.prototype.bullet    = function(x) { return $(this.template('bullet')({content: x})); }
Krill.prototype.image     = function(x) { return $(this.template('image')({content: x})); }
Krill.prototype.select    = function(x) { return $(this.template('select')(this.fix(x))); }
Krill.prototype.input     = function(x) { return $(this.template('input')(this.fix(x))); }
Krill.prototype.take      = function(x) { return $(this.template('take')(this.fix(x))); }
Krill.prototype.separator = function(x) { return $(this.template('separator')()); }

Krill.prototype.upload = function(x) {

  var y = this.fix(x);
  y.job = this.job;

  var container = $(this.template('upload')(y));
  var input = $('.krill-upload-input',container);
  var list = $('.krill-upload-list',container);
  var that = this;

  $(function(e) {

    input.fileupload({

      dataType: 'json',

      done: function (e, data) {
        console.log(data.result.upload_id);
        data.context.empty().append($(that.template('uploaded-item')({
          name: data.files[0].name,
          id: data.result.upload_id
        })));
      },

      add: function (e,data) {
        var el = $(that.template('upload-waiting')({name: data.files[0].name}));
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

Krill.prototype.table = function(x) {

  var tab = $('<table></table>').addClass('krill-table');

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

  return tab;

}