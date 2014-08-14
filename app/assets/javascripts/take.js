
function TakeUI(entries, tag, job, env) {

  this.entries = entries;
  this.tag = '#' + tag;
  this.job = job;
  this.env = env;
  this.release = [];

  console.log(this.env);

}

TakeUI.prototype.check = function(i,j) {

    var that = this;
    var ch = $("<input class='check' type='checkbox' id='check_'" + i + "_" + j + "'></input>");

    ch.click(function() {
        that.set_next();
    });

    return ch;

}

TakeUI.prototype.tospan = function(thing,name) {
  return $('<span class=' + name + '>' + thing[name] + '</span>' );
}

TakeUI.prototype.item_html = function(item,i,j) {

  var el =  $('<li class="take_item"></li>'), 
    id = this.tospan(item,'id'),
    description = this.tospan(item,'objecttype'),
    ch = this.check(i,j),
    that = this;

  if ( item.inuse == 0 ) {
    loc = this.tospan(item,'location');
  } else {
    loc = $("<span class='inuse'>Not available</span>");
    if ( this.env != 'production' ) {
      this.release.push(item.id);
      rel = $("<div class='release'><a href='#'>RELEASE</a></div>");
      rel.click(function() { window.location = 'release?item=' + item.id + '&job=' + that.job; } );
      loc.append(rel);
    }
    $(ch).attr("disabled", true);
  }

  if ( item.sample_name ) {
      var name = item.sample_name;
      if ( name.length > 24 ) {
        name = name.substring(0,24) + "...";
      }
      description = $('<span class="description">' + item.objecttype + ' : ' + name + '</span>' );
  }

  el.append(ch).append(id).append(loc).append(description);

  return el;

}

TakeUI.prototype.object_html = function(object,i,j) {

    var el =  $('<li class="take_object"></li>'),
       sel = $('<select id="select_' + i + '_' + j + '"></select>'),
       quantity = this.tospan(object,'desired_quantity'),
       name = this.tospan(object,'name'),
       ch = this.check(i,j),
       that = this;

    var max = 0;
    var temp = 0;
    for ( var k in object.items ) {
        temp = object.items[k].quantity - object.items[k].inuse;
        if ( temp >= object.desired_quantity ) {
          sel.append('<option value=' + object.items[k].id + '>' + object.items[k].location + '</option>');
        }
        if ( temp > max ) {
            max = temp;
	}
    }

    if ( max < object.desired_quantity ) {
	$(ch).attr("disabled", true);
        if ( this.env != 'production' && object.items.length > 0 ) {
          var id = object.items[0].id;
          this.release.push(id);
          rel = $("<a href='#'> RELEASE</a>");
          rel.click ( function() { window.location = 'release?item=' + id + '&job=' + that.job; } );
          quantity.append(rel);
        }
    }

    var selcontainer = $("<span class='take-select-container'></span>").append(sel);
    el.append(ch).append(name).append(selcontainer).append(quantity);
    return el;

}

TakeUI.prototype.show = function() {

  this.list = $("<ul class='item_list'></ul>");
  
  for ( var i in this.entries ) {
    var e = this.entries[i];
    if ( e.item_value != undefined ) { // Items ////////////////////////////
      for ( var j in e.item_list ) {
        var el =  this.item_html ( e.item_list[j], i, j ) ;
        this.list.append (el);
      }
    } else {
      for ( var j in e.object_list ) { // Objects //////////////////////////
        var object = e.object_list[j];
        var el =  this.object_html ( e.object_list[j], i, j ) ;
        this.list.append (el);
      }
    }
  }

  $(this.tag).append(this.list);

    console.log(this.release);

    if ( this.release.length > 0 ) { 
        var btn = $("<button>RELEASE ALL</button>").addClass("btn");
        var that = this;
        btn.click(function(e) {
            e.preventDefault();
	    window.location = "release?itemlist=[" + that.release + "]&job=" + that.job;
	});
        $(this.tag).append(btn);
    }

}

TakeUI.prototype.set_next = function() {

    var result = true;

    $(".check").each(function(i) {
	result = result && $(this).prop("checked");
    });

    document.getElementById('advance-button').disabled = !result;

}

TakeUI.prototype.query = function() {

  var choices=[];

  for ( var i in this.entries ) {

    var e = this.entries[i];
    choices.push(new Array());

    if ( e.item_value != undefined ) { // Items ////////////////////////////
      for ( var j in e.item_list ) {
          var item_info = { id: e.item_list[j].id };
          choices[i].push(item_info);
      }

    } else {
      for ( var j in e.object_list ) { // Objects //////////////////////////
        var object = e.object_list[j];
        var v = $('#select_'+i+'_'+j).val();
        var object_info = { id: v  };
        choices[i].push(object_info);
      }
    }

  }

  return '&take=' + encodeURIComponent(JSON.stringify(choices));

}